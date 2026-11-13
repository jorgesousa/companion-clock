# Companion Clock: notes for agents

The whole app is `index.html`, served from the clock at `http://localhost:8080` and shown in Fully Kiosk Browser. Device files are in `device/`, the calendar feed in `calendar/Code.gs`.

## The engine is WebView 74 (2019)

Write for Chrome 74. No `?.`, `??`, `inset`, `clamp()`, flex `gap`, `aspect-ratio`, `Animation.finished` (use `onfinish`), `clip-path` on text, flex on `<button>`. `[hidden]` needs `!important`. The page is 800×480 CSS px (`<meta name="viewport" content="width=800">` on a 1.5 DPR screen).

## Private values never go in the repo

The calendar URL and key, the steps topic, client brand colours and the playlist URL live only on the clock in `/data/local/companion-clock/config.json` and `m3u.url` (`chmod 600`). `config.json` and `m3u.url` are git-ignored. Screenshots and examples use fictional clients.

## Deploy and check

```bash
adb push index.html /data/local/tmp/
adb shell 'su -c "mv /data/local/tmp/index.html /data/local/companion-clock/index.html; chmod 644 /data/local/companion-clock/index.html"'
adb shell am start -n de.ozerov.fully/.MainActivity -a android.intent.action.VIEW -d http://localhost:8080/
adb exec-out screencap -p > shot.png
```

Look at the real screen after every change. To test without the clock, serve the folder locally with an `events.json` of fictional events and open it at 800×480.

## Shell on the clock

Magisk runs `device/boot.sh` with BusyBox: call `/system/bin/nc` explicitly (BusyBox `nc` has no `-L`). Never run `pkill -f` / `pgrep -f` with the server's command line inside an `su -c "..."` string: the pattern matches the shell running it and kills your own command. Put such steps in a script file.
