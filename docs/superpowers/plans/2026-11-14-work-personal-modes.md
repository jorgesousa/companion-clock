# Work / Personal Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One tap on "JS" switches the clock between WORK and PERSONAL; Personal shows the personal Google Calendar and a Sporting card in place of the meeting card.

**Architecture:** One personal Apps Script (`personal/Code.gs`, already deployed as "Companion Clock Football") serves football, the league table and the personal calendar. `index.html` keeps a `mode` ('work' | 'personal') in localStorage, picks the calendar source by mode, and renders the Sporting card inside the existing `#h-next-blk`, reusing the meeting line (`#h-live`) and the `attn` rule.

**Tech Stack:** single-file `index.html` (WebView 74: no `?.`, `??`, `inset`, `clamp`, flex `gap`), Google Apps Script, football-data.org v4.

**Spec:** `docs/superpowers/specs/2026-11-14-work-personal-modes-design.md`

## Global Constraints
- Mode switch is manual only (tap "JS"); persisted in localStorage key `mode`, default `work`.
- Header label: `JS · WORK` / `JS · PERSONAL`.
- Team id from config `footballTeam` (default `498`, Sporting); competition `PPL`.
- Secrets only in the clock's `config.json`: `footballUrl`, `footballToken`, `personalCalUrl` (with `?k=`). Never in the repo, screenshots or video.
- Cache in the script: 10 min, 1 min while a match is live; clock polls every 10 min, every 60 s while live.
- Long text glides (marquee), never "…". Colour = state. Every change animates (crossfade/slide).
- Prints sent to the user with Weather off; fictional data only in repo screenshots.

## Review Focus
1. Personal calendar feed unreachable or not yet authorized → Personal calendar shows the existing "offline" state, Work calendar is untouched.
2. No upcoming Sporting match in the 30-day window (season break) → card says "No match scheduled" with the table position still shown.
3. Match live but the API lags (status still TIMED after kick-off) → treat kick-off ≤ now < kick-off+120 min as live-ish: show "Kick-off 20:30 · Live soon" rather than a stale "Next".
4. Switching mode mid-browse (meeting carousel open, Free/Until flip pending) → state resets cleanly, no stale timers firing into the other mode.
5. Token rejected (403/429 from football-data) → card shows last good data; after 1 h with no data, "Football data unavailable".

---

### Task 1: Personal script serves table and calendar

**Files:**
- Rename: `football/Code.gs` → `personal/Code.gs`
- Modify: `personal/Code.gs` (live copy: Apps Script project "Companion Clock Football", personal account)

**Interfaces:**
- Produces: `GET <footballUrl>?f=football&teams=498&ft=<token>` → `[{team, matches:[{utc,status,comp,home,homeId,away,awayId,score:[h,a]|null}]}]` (unchanged; `f` optional, default football)
- Produces: `GET <footballUrl>?f=table&comp=PPL&ft=<token>` → `[{pos, teamId, team, pts, played}]`
- Produces: `GET <footballUrl>?f=calendar&k=<KEY>` → same JSON as the work calendar (`[{start,end,title,allDay,type}]`)

- [ ] **Step 1:** Add `table(comp, token)` (GET `/v4/competitions/{comp}/standings`, first TOTAL table) and `calendar()` (copy of the work script's event mapping, guarded by `KEY`); route by `p.f`. Live-match cache: 60 s when any match status is `IN_PLAY` or `PAUSED`, else 600 s.
- [ ] **Step 2:** The script makes its own key: `authorize()` creates `KEY` once with `Utilities.getUuid()` in Script Properties and logs it; `calendar()` compares `p.k` with it. Read the key from the execution log and put it only in the clock `config.json` as part of `personalCalUrl` (nobody types a key into a web form).
- [ ] **Step 3:** Save, user runs `authorize` (Calendar scope) and approves; deploy a new version of the existing web app (same URL).
- [ ] **Step 4: Verify**
  Run: `curl -sL "<footballUrl>?f=table&comp=PPL&ft=<token>"` → JSON array with 18 rows, one `teamId:498`.
  Run: `curl -sL "<footballUrl>?f=calendar&k=<KEY>"` → JSON array (may be empty), not `forbidden`.
- [ ] **Step 5:** Write `personalCalUrl`, `footballTeam: 498` into the clock config (chmod 600); commit `personal/Code.gs` + config.example keys.

### Task 2: Mode state, header and calendar by mode

**Files:** Modify `index.html` (header `#net`, `loadEvents`, prefs/startup)

**Interfaces:**
- Produces: `var mode` ('work'|'personal'); `setMode(m)`; `body.personal` class; `calUrl()` returns `cfg.personalCalUrl` in personal else `cfg.calendarUrl`.
- Consumes: Task 1 `?f=calendar` JSON.

- [ ] **Step 1:** `#net` becomes a button again (pointer-events on), label `JS · WORK|PERSONAL` (mode word in muted mono, slides on change). Tap → `setMode(other)`.
- [ ] **Step 2:** `setMode(m)`: save, toggle `body.personal`, reset `nOff`, `freeAlt`, `events=null` (keep a per-mode cache so switching back is instant), crossfade `#cal-list` and `#h-next-blk`, call `loadEvents()` and `renderNext()`.
- [ ] **Step 2b:** TV tab hidden in WORK (nav slides to close the gap; if TV is open when switching to WORK, go Home). Accent per mode: localStorage `accent` (work) and `accentPersonal`; the brand slot in Settings is `cfg.brandAccent` (Mindera) in WORK and `cfg.brandAccentPersonal` (Sporting) in PERSONAL.
- [ ] **Step 2c:** The split-flap transition from the spec (spark, hours flap, staggered row flips, circle colour reveal from JS, label slide), ~1.2 s, `prefers-reduced-motion` → instant.
- [ ] **Step 3: Verify (local test copy)** inject `cfg.personalCalUrl` to a local JSON with 2 fictional personal events; toggle; Calendar shows them; toggle back shows work events; reload keeps the mode.
- [ ] **Step 4:** Deploy to the clock; prints of both modes (Weather off); commit.

### Task 3: Football data on the clock

**Files:** Modify `index.html` (new block near weather code)

**Interfaces:**
- Produces: `loadFootball()`; `fb = {matches:[...sorted by utc], table:{pos,pts}, at:Date}`; `fbLive()` → current live match or null; `fbNext()` → next not-finished match; `fbLast()` → last FINISHED match within 24 h.
- Consumes: Task 1 endpoints; `cfg.footballUrl`, `cfg.footballToken`, `cfg.footballTeam`.

- [ ] **Step 1:** Fetch football + table on start and every 10 min; every 60 s while `fbLive()`; keep last good data on error; mark unavailable after 1 h without data.
- [ ] **Step 2: Verify** in the browser console of the test copy: `fbNext()` returns the Porto–Sporting match object for the captured real data; `fb.table` = `{pos:<n>, pts:<n>}`.
- [ ] **Step 3:** Commit.

### Task 4: The Sporting card

**Files:** Modify `index.html` (`renderNext`, `meetLine`, `attn` toggle, card tap handler, CSS)

**Interfaces:**
- Consumes: Task 3 `fbLive()`, `fbNext()`, `fbLast()`, `fb.table`; existing `#h-live`, `meetLine()`, `marquee()`, body `attn`.

- [ ] **Step 1:** In personal mode `renderNext` renders:
  - live → value `Sporting 2–1 Porto` (accent), label `Live · Primeira Liga`, `#h-live` fills over kick-off → +105 min, `attn` on;
  - next → value `20:30`, small `Porto – Sporting` (glides if long), label `Next · Sat 29 Nov · Primeira Liga`, line burns down in the last 15 min (same as meetings);
  - just finished (< 24 h) → value `Won 3–1` / `Lost 1–2` / `Draw 1–1`, small opponent;
  - none → `No match scheduled`;
  - label right side always `1st · 28 pts` (ordinal, `.pos` style like `1/2`).
- [ ] **Step 2:** Tap/swipe the card in personal → cycle through the next 3 fixtures with the existing crossfade; back to default after 10 s.
- [ ] **Step 3: Verify** local test copy with injected `fb` for the four states (next, 10 min before, live, finished): prints of each; on the clock, print of the real next match.
- [ ] **Step 4:** README (modes, Sporting card, personal script), ROADMAP (football done), config.example (`footballUrl`, `footballToken`, `footballTeam`, `personalCalUrl`); commit; push after the user approves.
