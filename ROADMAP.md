# Roadmap

## Next

- **Snooze on the ringing sheet.** Push the sheet up to snooze: a timer restarts with a few more minutes, an alarm rings again later (duration to decide: +1, +5 or +10 min).
- **Reminders and to-dos.** First analyse which source fits how the work actually happens: a MacBook for work, Mindera on Google Workspace, and a client on Microsoft 365. Routes to compare (sign-in and tenant policies, what each one sees, effort), then pick one or merge a few:
  - *Google Tasks*: add Tasks to the existing work Apps Script and return today's tasks with the events; no new sign-in.
  - *Apple Reminders*: a Shortcut on the Mac or iPhone posts due reminders to a private ntfy topic, the same path the steps use; works across accounts, but only for what lands in Reminders.
  - *Microsoft To Do / Outlook flagged email* (client's Microsoft 365): Microsoft Graph needs an app consent the client's tenant may not allow; a Power Automate flow posting to ntfy may be the realistic path, if the tenant permits it.
  - On the clock: today's to-dos on Home (a card like the meeting, or a count), ticked off on the phone or Mac, never on the clock.
- **One pattern for everything that needs you.** The water reminder set it: the cell floods with the accent (the colour travels to it) and stays still, a short chime (never during a meeting: it waits for it to end), and tapping it to say "done" crumbles it into grain that bursts and falls (effect G). List every case where the clock should call for attention and give each the same rule and effect, so the app speaks one language. Candidates:
  - a meeting about to start (today: the time turns to the accent and a line burns down) and the "Ready for it?" prompt below;
  - an orange or red IPMA weather warning starting;
  - reminders and to-dos falling due;
  - "Claude is waiting for you" (Claude Code hooks);
  - an important unread email;
  - steps far behind late in the work day, once the steps pace is revisited.
  Decide for each: what floods (which cell), whether it chimes, and what "done" means (dismiss, snooze, open).
- **"Ready for it?" before a meeting.** Ahead of a meeting, the clock asks whether you're ready for it. If not, it suggests using the free time before it to prepare (e.g. "40 min free before Sprint review: prepare now?"), pointing at that Free slot. To decide: how far ahead to ask, which meetings (all, or only some), and what "prepare" turns into (a focus block, a timer).
- **Claude Code → clock.** `Notification` / `Stop` hooks post to a private ntfy topic; the clock shows "Claude is waiting for you".
- **Unread email** via the same Apps Script: unread count and the last important sender on Home.
- **Steps pace, revisited.** "Expected X · N ahead/behind" is switched off for now: it paced 10,000 steps over the working day (08:00 to `dayEndMinute`) every day, weekends too. Decide a pace that fits (work days vs weekends, a different window) or keep just the count.
- **Microphone indicator.** Replace the assistant's overlay with the clock's own mic-off icon; needs the mute switch state source first.
- **Type scale pass.** 9 sizes → 5 (18 · 24 · 44 · 84 · 210) and 3 type styles.
- **DESIGN.md.** Document the design system (tokens, type scale, components) from the built app.

## Ideas (not committed)

- Morning briefing written by Claude (meetings and email in three lines).
- GitHub: pull requests waiting for review, CI status of your own pull requests.
- Countdown takeover two minutes before a meeting.

## Known issues

- **Ghost touch.** The touch panel sometimes keeps reporting a touch with no finger on it (stuck on the top edge, or glued to one point), so the screen looks frozen. `device/boot.sh` detects both shapes and resets the panel within about 4 seconds; see [docs/setup.md](docs/setup.md#touch-panel-stops-responding-ghost-touch). Likely a hardware quirk of this panel.

## Done

- Local server, boot script with self-repair, ADB over Wi-Fi (firewalled to one IP).
- Design aligned with jorgesousa.github.io; English UI; manual sleep mode with brightness control.
- Calendar via an Apps Script web app: today to the end of next week, declined events hidden, working location per day (Office highlighted), a red rule with the week number where next week starts.
- Free time: gaps of 15+ min inside 09:00–17:00 shown as hatched Free rows; the slot you are in stands out as "Free now · Xh left".
- Home: current meeting is live (dot, accent time, filling rule); swipe or tap to browse today's later meetings; long titles glide.
- Steps (ntfy) against a 10,000 goal; hourly water reminders on work days (tap to count the glass).
- TV player for your own HLS playlist, through a local playlist proxy.
- Settings (tap "JS"): brightness 10–100% and 8 accent colours.
