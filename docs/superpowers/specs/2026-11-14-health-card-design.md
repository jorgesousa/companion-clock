# Health card (steps and water)

## Intent

The water's job is to remind you to drink when you aren't, not to be a tracker you look at. While you're on track it stays out of sight; Health is a place with pages, so more health things can be added later as pages, not as more elements in one card.

## Approaches

1. **A page per topic** (picked): Steps and Water pages in the same card, swipe between them, tap acts on the page you see. The water page shows itself only when you're behind.
2. Summary first, details after: one small summary page plus a page per topic. Rejected: more pages and taps for the same thing.
3. Pages rotating on their own every few seconds. Rejected: constant motion is tiring, and the page can change as you reach for it.

Earlier visual takes (glasses next to the number, bottle, number filling, half as a glass, jug) were rejected: too much in one small card, and the water drawing changed with the step count.

## Design

- **Steps page** (default): "57 steps", and below "9,943 to go" (or "Goal reached"). Tap: sync now.
- **Water page**, on work days only:
  - **Behind** (fewer glasses than the reminders so far, spread 09:00 to 17:00): the card turns to the water page by itself. "Time for water" large in the accent, "Tap when you drink · 3/9" below; the accent travels to it (the hours go white, as before a meeting).
  - **Browsing** (swipe to it): "0.75 L" large, "3 of 9 glasses · next 12:25".
  - **Tap** counts a glass: "+1" pops, the litres count up, and if you're no longer behind the card goes back to steps. A second tap within a moment takes it back.
  - Swiping away from "Time for water" snoozes it for 15 minutes. Browsing returns to steps after 10 seconds.
- **Motion, the moment that makes it**: water rises inside the card. The page turn is a water level rising from the bottom of the card in the accent tint, with a moving wave on top, while the steps blur away and the water text comes into focus. Drinking drains the level ("glug") as "+1" pops; leaving the page lets it fall away.
- Page dots "1/2" / "2/2" as in the other cards, on work days.
- Settings → Health keeps the steps goal and the glasses a day.

## Left to the builder

Exact timings and curves, the wave shape, how far the level rises.
