# Roadmap

## Next

- **A new look for the time.** The big digits (hours solid in the accent, minutes outlined and overlapping them in a staircase, seconds beside) have run their course. Explore fresh directions before choosing, in the browser first, with the design skills: `impeccable` (critique of today's Home, then typeset / bolder / overdrive for options), `design-taste-frontend` (directions that don't look templated), `better-typography` (scale, figures, tracking for numbers read from a metre), and `emil-design-eng` / `animate` for how the minute changes. Constraints to keep: 800×480 on WebView 74, readable from across the desk, one accent per mode, and the time stays the hero. Decide with it: where the weather lives (today inside the outlined minutes), how Sleep and the alarm / meeting card follow the new digits, and how the minute change animates.
- **Reminders and to-dos.** First analyse which source fits how the work actually happens: a MacBook for work, Mindera on Google Workspace, and a client on Microsoft 365. Routes to compare (sign-in and tenant policies, what each one sees, effort), then pick one or merge a few:
  - *Google Tasks*: add Tasks to the existing work Apps Script and return today's tasks with the events; no new sign-in.
  - *Apple Reminders*: a Shortcut on the Mac or iPhone posts due reminders to a private ntfy topic, the same path the steps use; works across accounts, but only for what lands in Reminders.
  - *Microsoft To Do / Outlook flagged email* (client's Microsoft 365): Microsoft Graph needs an app consent the client's tenant may not allow; a Power Automate flow posting to ntfy may be the realistic path, if the tenant permits it.
  - On the clock: today's to-dos on Home (a card like the meeting, or a count), ticked off on the phone or Mac, never on the clock.
- **One pattern for everything that needs you.** The water reminder set it: the cell floods with the accent (the colour travels to it) and stays still, a short chime (never during a meeting: it waits for it to end), and tapping it to say "done" crumbles it into grain that bursts and falls. The alarm, the timer and the meeting heads-up now follow it too (one centred card that crumbles away). Still to give the same rule and effect, so the app speaks one language:
  - the "Ready for it?" prompt below;
  - an orange or red IPMA weather warning starting;
  - reminders and to-dos falling due;
  - "Claude is waiting for you" (Claude Code hooks);
  - an important unread email;
  - steps far behind late in the work day, once the steps pace is revisited.
  Decide for each: what floods (which cell), whether it chimes, and what "done" means (dismiss, snooze, open).
- **"Ready for it?" before a meeting.** Ahead of a meeting, the clock asks whether you're ready for it. If not, it suggests using the free time before it to prepare (e.g. "40 min free before Sprint review: prepare now?"), pointing at that Free slot. To decide: how far ahead to ask, which meetings (all, or only some), and what "prepare" turns into (a focus block, a timer).
- **Claude Code → clock.** Claude Code hooks post to a private ntfy topic (its name only in `config.json`); the clock listens live (ntfy's SSE stream, so it arrives in about a second instead of on the next minute poll) and shows it on the same card as the alarm and the meeting heads-up. `Notification` only (a permission request, or waiting for your answer): `Stop` fires after every reply and would never let the clock rest. The same topic can take any message you send yourself.
- **Hourly email summary.** Working on a client's systems all day, the Mindera inbox goes unwatched: once an hour the clock says what's waiting there. Routes:
  - *The work Apps Script* (preferred): an hourly trigger in the Mindera Google account reads the unread inbox and builds the summary (how many, who from, the subjects, important first); the clock fetches it like the calendar. The email never leaves Google and the clock, and it runs with the laptop closed. A Claude-written summary would need an API key in the script and send the content to Anthropic: only if Mindera allows it.
  - *A Claude scheduled task with the Gmail connector*: the best summary, also with the laptop closed, but the content goes through Anthropic and ntfy.
  - *An hourly `claude -p` job on the Mac*: only while the Mac is on.
  Decide with it: what counts as important, whether it's a card on the hour or a quiet line on Home, and work days only.
- **Steps pace, revisited.** "Expected X · N ahead/behind" is switched off for now: it paced 10,000 steps over the working day (08:00 to `dayEndMinute`) every day, weekends too. Decide a pace that fits (work days vs weekends, a different window) or keep just the count.
- **Microphone indicator.** Replace the assistant's overlay with the clock's own mic-off icon; needs the mute switch state source first.
- **Type scale pass.** 9 sizes → 5 (18 · 24 · 44 · 84 · 210) and 3 type styles.
- **DESIGN.md.** Document the design system (tokens, type scale, components) from the built app.

## Ideas (not committed)

- Morning briefing written by Claude (meetings and email in three lines).
- GitHub: pull requests waiting for review, CI status of your own pull requests.

## Known issues

- **Ghost touch.** The touch panel sometimes keeps reporting a touch with no finger on it (stuck on the top edge, or glued to one point), so the screen looks frozen. `device/boot.sh` detects both shapes and resets the panel within about 4 seconds by turning the screen off and on (it blinks for about 2 seconds); see [docs/setup.md](docs/setup.md#touch-panel-stops-responding-ghost-touch). Likely a hardware quirk of this panel.

## Done

- Local server, boot script with self-repair, ADB over Wi-Fi (firewalled to one IP).
- Design aligned with jorgesousa.github.io; English UI; manual sleep mode with brightness control.
- Calendar via an Apps Script web app: today to the end of next week, declined events hidden, working location per day (Office highlighted), a red rule with the week number where next week starts.
- Free time: gaps of 15+ min inside 09:00–17:00 shown as hatched Free rows; the slot you are in stands out as "Free now · Xh left".
- Home: current meeting is live (dot, accent time, filling rule); swipe or tap to browse today's later meetings; long titles glide.
- Health card: steps (ntfy) against a goal, and on work days in WORK the glasses of water, spread evenly from 09:00 to 17:00; falling behind floods the water half, and a tap crumbles the reminder.
- TV player for your own HLS playlist, through a local playlist proxy.
- Work and Personal modes (tap "JS"): each with its own calendar and accent; PERSONAL adds TV and a Sporting card (next match, live score, position, last result).
- Weather inside the digits (Open-Meteo, checked against the nearest IPMA station) and IPMA weather warnings for your district.
- Sleep: a dim ember clock on true black, from a button or the night hours.
- Alarm and timer ring as a centred card in the accent that crumbles away on a tap; alarms add a line for the day ahead.
- Meeting heads-up in WORK, 5 minutes before each meeting.
- Settings (the sliders icon): brightness 10–100%, 8 accent colours, mute in meetings, Weather Live / Off, the temperature tap, the club logo, Health goals.
- Ghost-touch watchdog in `device/boot.sh`.
