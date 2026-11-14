# Work / Personal modes — design

## Intent
At the end of the day (or any time) the clock should stop being about work. One tap on "JS" switches between **WORK** and **PERSONAL**. Personal shows your own calendar and Sporting instead of meetings. The switch is always manual.

## What changes per mode

| | WORK (today) | PERSONAL |
|---|---|---|
| Header, left | `● JS · WORK` | `● JS · PERSONAL` |
| Home, top card | next meeting / Free / Weekend | **Sporting** |
| Home, rest | unchanged (time, weather, steps, bottom strip) | unchanged |
| Calendar | work Google Calendar | personal Google Calendar |
| Clock | unchanged | unchanged |
| TV | **hidden** (not in the nav) | shown |

The mode survives reloads (saved on the clock).

**The switch is a moment (it has to be WOW): a split-flap board turning over (~1.2 s).**
1. A spark in the accent shoots from "JS" across the header (the fuse's gesture).
2. The big hours flip down like a flap (shadow mid-turn); then the right-column rows flip one after another, top to bottom, ~90 ms apart; each lands with the new mode's content.
3. The accent colour changes: each mode remembers its own accent choice, and the brand slot in Settings follows the mode (WORK: **Mindera** `#ffc500`; PERSONAL: **Sporting** `#00a651`, from config `brandAccent` / `brandAccentPersonal`). The new colour opens from "JS" as a circle across the screen.
4. The label: WORK slides up and out, PERSONAL slides in from below.
5. TV leaves / joins the nav with the other tabs sliding to close the gap.
If the clock's GPU stutters, keep the hours flip and the colour circle, and simplify the row flips.

## The Sporting card (same card, same rules as the meeting card)
- **Before a match:** big value is the kick-off time ("20:30"), under it "Porto – Sporting"; label "Next · Sat 29 Nov · Primeira Liga". 15 minutes before kick-off the line burns down, exactly like a meeting.
- **Live:** big value is the score "Sporting 2–1 Porto" in the accent; label "Live · Primeira Liga"; the line fills as the match goes (from kick-off to about 105 min). Score updates every minute while live.
- **Just finished (until the next day):** "Won 3–1 · Moreirense" / "Lost" / "Draw", then back to the next match.
- **Always, right side of the label:** league position, e.g. "1st · 28 pts".
- Tap the card: shows the next 3 fixtures (like browsing today's meetings).

Colour rule holds: the accent marks state (live, about to start); the hours give the colour up while it's live, like a meeting.

## Data
- One Apps Script in your **personal** Google account ("Companion Clock Football", already live) serves everything personal:
  - `?f=football&teams=498` → recent and upcoming matches (done).
  - `?f=table&comp=PPL` → league table, to find Sporting's position (new).
  - `?f=calendar&k=<KEY>` → your personal calendar, same JSON shape as the work one (new; needs a Calendar authorization from you once; guarded by a random key like the work one).
- The football-data.org token and the script URL/key live only in the clock's `config.json`.
- Cache: 10 min normally, 1 min while a match is live (free tier: 10 calls/min).

## Approaches considered
1. **Personal script does calendar + football (chosen).** One place for personal data, one authorization flow, works around the work account blocking external calls.
2. Work script does football too — rejected: the work account blocks external requests.
3. Clock calls football-data.org directly on port 80 — possible, but it would still need a second script for the personal calendar, and it depends on the API keeping `http://localhost` allowed.

## Out of scope (for now)
- Automatic switching by time or day.
- Other teams or a team picker on the clock (the team id is a config value: 498).
- Hiding work things in Sleep or the bottom strip.

## Open, to confirm while building
- How fresh live scores are on the free tier (seconds vs minutes); if they lag a lot, the card says "Live" without pretending to be real-time.
