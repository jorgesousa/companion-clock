# Roadmap

## Next

- **Weather support.** Today's weather on the clock (source and where it shows to decide).
- **Snooze on the ringing sheet.** Push the sheet up to snooze: a timer restarts with a few more minutes, an alarm rings again later (duration to decide: +1, +5 or +10 min).
- **Football fixtures.** Next games for chosen teams (ESPN's public API for the top league and cup; a second source for lower leagues, fetched through the Apps Script because it has no CORS).
- **Reminders.** Two routes to decide between:
  - *Google Tasks*: add Tasks to the existing Apps Script and return today's tasks with the events; no new sign-in.
  - *Apple Reminders*: an iOS Shortcut posts due reminders to a private ntfy topic, the same path the steps use.
- **Claude Code → clock.** `Notification` / `Stop` hooks post to a private ntfy topic; the clock shows "Claude is waiting for you".
- **Unread email** via the same Apps Script: unread count and the last important sender on Home.
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
- Steps (ntfy) with pace: "Expected X · N ahead/behind".
- TV player for your own HLS playlist, through a local playlist proxy.
- Settings (tap "JS"): brightness 10–100% and 8 accent colours.
