<div align="center">

# Companion Clock

**The clock on your desk that knows what's next.**

A Xiaomi Mi Smart Clock turned into a work companion: the time, your next meeting and the free time around it, your steps, timers, alarms and a TV player, all served from the clock itself.

[![Check](https://github.com/jorgesousa/companion-clock/actions/workflows/check.yml/badge.svg)](https://github.com/jorgesousa/companion-clock/actions/workflows/check.yml)
![Android Things 10](https://img.shields.io/badge/device-Mi%20Smart%20Clock-111)
![WebView 74](https://img.shields.io/badge/WebView-74-555)
[![License: Sustainable Use 1.0](https://img.shields.io/badge/license-Sustainable%20Use%201.0-8B5CF6)](LICENSE.md)

<img src="docs/screenshots/home.jpg" width="800" alt="Home: the time in large type (hours solid, minutes outlined), the date, the next meeting with how long until it starts, and today's steps against a 10,000 goal">

</div>

---

## Why

A desk clock sees you all day, and all it knew was the time. Companion Clock answers the next three questions at a glance, from a metre away: **what time is it, what's next, am I moving enough.** Everything else (a timer, an alarm, a channel) is one tap away.

## A look around

<table>
<tr>
<td width="50%" valign="top">
<img src="docs/screenshots/calendar.jpg" alt="Calendar: today's meetings with a coloured square per client, hatched green Free rows between them, and the free slot you are in shown live">
<b>Calendar.</b> Today to the end of next week. Free time between meetings is hatched in green, and the slot you're in right now counts down.
</td>
<td width="50%" valign="top">
<img src="docs/screenshots/calendar-week.jpg" alt="Calendar further down: a red rule reading Week 47 · 16–22 Nov marks where next week starts; Monday's heading says Office in red">
<b>Next week.</b> A red rule with the week number marks where it starts. Office days stand out in the day's heading.
</td>
</tr>
<tr>
<td width="50%" valign="top">
<img src="docs/screenshots/timer.jpg" alt="Timer: 25:00 in large type with presets from 5 to 60 minutes, Start and Reset">
<b>Timer and alarms.</b> One-tap presets, big steppers for alarms, the next alarm on Home.
</td>
<td width="50%" valign="top">
<img src="docs/screenshots/settings.jpg" alt="Settings: brightness from 10 to 100 percent and eight accent colours">
<b>Settings.</b> Tap <code>JS</code>: brightness and eight accent colours.
</td>
</tr>
</table>

<sub>Screenshots use fictional clients and data.</sub>

## What it does

- **Home.** Hours solid, minutes outlined, seconds beside them. The next meeting, with "in 12 min"; 15 minutes before it the block turns into the accent colour. While a meeting runs, its start time is in the accent, a dot pulses and a line fills as it goes. Swipe or tap to see today's later meetings. Long titles glide to show the end.
- **Steps.** Today's count against 10,000, with the pace you should be at by now ("Expected 3,820 · 1,040 ahead").
- **Calendar.** Grouped by day, with a summary per day ("4 meetings · 4h free"). Free time is counted inside the working day (09:00–17:00, Monday to Friday) in gaps of 15 minutes or more. Each client in `[Brackets]` gets its own colour, or its brand colour if you set one.
- **Working location.** Google Calendar's Home / Office shows in each day's heading; Office in the accent.
- **Timer and alarms.** Presets from 5 to 60 minutes; alarms ring full-screen until you tap.
- **Sleep.** One button dims the screen to almost nothing and leaves the time drifting slowly.
- **TV.** Plays an HLS playlist (M3U) you provide. Ships with no channels; use only playlists you're entitled to.
- **Settings.** Brightness 10–100% and eight accent colours, remembered on the clock.

## How it works

- **One HTML file.** [`index.html`](index.html) holds the whole app: inline CSS, JavaScript and SVG icons. It targets the clock's WebView 74, so no `?.`, `??`, `inset`, `clamp()` or flex `gap`.
- **Served from the clock.** [`device/serve.sh`](device/serve.sh) is a tiny HTTP server on `127.0.0.1:8080`, run by the clock's own `nc`. It serves the page, the config, self-hosted fonts and hls.js, the playlist proxy and a brightness endpoint. Nothing is hosted anywhere else.
- **Starts itself.** [`device/boot.sh`](device/boot.sh) runs at boot: it starts the server, restarts it if it ever stops, keeps the kiosk browser in front, and resets the touch panel if it gets stuck.
- **Calendar.** A Google Apps Script web app in your own account ([`calendar/Code.gs`](calendar/Code.gs)) returns your events as JSON, guarded by a random key. The clock asks for it every 5 minutes.
- **Steps.** Read from an [ntfy.sh](https://ntfy.sh) topic that your phone posts to (for example with [Unsit](https://github.com/jorgesousa/Unsit)).
- **Private values stay on the clock.** The calendar URL and key, the steps topic and the playlist URL live only in the clock's `config.json` and `m3u.url`, never in this repo. See [`config.example.json`](config.example.json).

## Install

Companion Clock runs on a Mi Smart Clock that you've already set up with root access (Magisk) and [Fully Kiosk Browser](https://www.fully-kiosk.com). Unlocking a device can void its warranty; do it only on your own device and at your own risk. This repo doesn't cover that step.

Then follow [docs/setup.md](docs/setup.md): copy the files to the clock, add your `config.json`, point Fully at `http://localhost:8080/`, and deploy the calendar script.

## Credits

Crafted by [Jorge Sousa](https://jorgesousa.github.io). Built with [Claude](https://claude.ai). Type: [Inter Tight](https://github.com/rsms/inter) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/) (SIL Open Font License). Video: [hls.js](https://github.com/video-dev/hls.js) (Apache 2.0).

## License

[Sustainable Use License 1.0](LICENSE.md): free for personal and non-commercial use.
