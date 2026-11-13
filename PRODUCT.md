# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Single static HTML file (inline CSS/JS, inline SVG icons), served locally on the clock by a toybox `nc` HTTP server at `http://localhost:8080`, shown full-screen in Fully Kiosk Browser. Fonts (Inter Tight, JetBrains Mono) and hls.js are self-hosted under `/a/`.

## Users

One person at a desk: someone who works from a calendar all day and wants the clock next to them to answer the next question before they ask it. The clock is read at a glance, at arm's length, during the working day.

## Product Purpose

Companion Clock turns a Xiaomi Mi Smart Clock into a personal desk companion: time and date, the next meeting and the free time around it, daily step progress, timers and alarms, and a TV player for your own playlist. Glance priority, in order: time, next meeting, steps. Success means one glance answers "what time is it, what's next, am I moving enough", and every action (start a timer, set an alarm, play a channel) takes one tap.

## Positioning

A personal, self-hosted display tied to the owner's own tools and visual identity, instead of a generic smart-home screen. Everything is served from the clock itself; nothing is hosted elsewhere.

## Operating Context

- Device: Xiaomi Mi Smart Clock (X04G), 800×480 landscape touchscreen, Android Things 10.
- Rendering engine: Android System WebView 74 (2019). No `?.`, `??`, `inset`, `clamp()`, flex `gap`, `aspect-ratio`; `[hidden]` needs `!important` against display rules.
- Always on. Touch only; no keyboard, no hover.

## Capabilities and Constraints

- Interface in English (en-GB, 24-hour).
- Steps: polled each minute from an ntfy.sh topic, goal 10,000, with a pace marker until the end of the working day.
- Calendar: a Google Apps Script web app in the owner's own Google account (execute as owner, guarded by a random key) returns events and working location as JSON. Its URL lives only in the clock's `config.json`. Declined events are excluded.
- Free time: gaps of 15+ minutes inside the working day (09:00–17:00, Monday to Friday) are shown as Free rows; the slot you are in right now is live.
- Timer with presets; alarms with hour/minute steppers stored in localStorage; the next alarm shows on Home.
- Sleep mode: manual, via the Sleep button; brightness through the local server (`/bright`).
- TV: plays an HLS playlist (M3U) the owner provides. Ships with no channels.
- Private values (calendar URL and key, steps topic, playlist URL) live only on the device (`config.json`, `m3u.url`), never in the page source.

## Brand Commitments

Aligned with https://jorgesousa.github.io/: its palette tokens, Inter Tight + JetBrains Mono, and editorial tone are the binding reference.

## Evidence on Hand

Real data only: live time, steps, calendar. Never fabricate events; screenshots in this repo use fictional clients.

## Product Principles

1. Glance first: the most important answer is readable from a metre away in under a second.
2. One tap to act: timers, alarms and channels start from a single touch.
3. Quiet when idle: an always-on object on a desk must not shout.
4. Personal, not generic: it should feel like the owner's own object, continuous with his website.
