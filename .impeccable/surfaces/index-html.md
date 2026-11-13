---
version: 1
slug: "index-html"
primary_target: "index.html"
related_targets: []
---

# Companion Clock (clock display) — surface brief

Scope: the whole Companion Clock app on the Mi Smart Clock (800×480, touch, WebView 74). Mode: Operate.
Job: at a glance, time → next meeting → steps; one tap to start a timer or play a channel.

## Direction contract

THESIS: The clock is a page of jorgesousa.github.io set as an object: the time stacked like the site's name, hours solid and minutes outlined. It refuses the dashboard of rounded cards, rings and icon tiles.

OWN-WORLD: Warm near-black #0e0e0c, raised #161614, bone #f2efe8, muted #8f8b80, hairlines #2a2925, one accent #e8473a (warm red, chosen by the user over the website orange #ff5b2e) for "needs you" (behind pace, meeting soon, timer ending, active tab rule). Inter Tight 800 tight-tracked for every number; JetBrains Mono 12px uppercase tracked for labels and data captions. Hairline rules, no radius above 4px, no shadows except the player scrim.

STORY: Glance: time, then the next meeting and how soon, then steps against pace. Touch: the mono nav switches Home/Calendar/Timer/TV; presets and channels start in one tap.

FIRST VIEWPORT: 48px mono header (JS left, nav centred, status right). Left 52%: hours 172px solid over minutes 172px outlined, bottom-aligned. Right column bottom-aligned: date caption over a hairline, next meeting (time 46px + title 20px, caption "PRÓXIMA · EM 28 MIN" with accent), hairline, steps (46px, caption "PASSOS DE 10 000 · N ATRÁS").

FORM: Hora em duas linhas, position 2 on the ordered list. seed:4f0cddad80418906

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
