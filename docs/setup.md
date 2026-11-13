# Setup

You need a Mi Smart Clock with root access (Magisk) and ADB, [Fully Kiosk Browser](https://www.fully-kiosk.com) installed, and a Mac or PC with `adb`.

Everything lives in `/data/local/companion-clock` on the clock.

## 1. Copy the app

```bash
adb push index.html device/serve.sh assets /data/local/tmp/cc/
adb shell 'su -c "mkdir -p /data/local/companion-clock && cp -r /data/local/tmp/cc/* /data/local/companion-clock/ && rm -r /data/local/tmp/cc"'
```

## 2. Add your config

Copy [`config.example.json`](../config.example.json), fill it in, and push it as `config.json`. Keep it private:

```bash
adb push config.json /data/local/tmp/
adb shell 'su -c "mv /data/local/tmp/config.json /data/local/companion-clock/; chmod 600 /data/local/companion-clock/config.json"'
```

| Key | What it is |
|---|---|
| `calendarUrl` | Your Apps Script web app URL with `?k=<KEY>` (step 4) |
| `unsitCode` | The code of the ntfy topic your phone posts steps to (`unsit-<code>`) |
| `dayEndMinute` | End of your day for the steps pace, in minutes after midnight (1035 = 17:15) |
| `brandColors` | Optional: a fixed colour per client, keyed by the name in `[Brackets]`, lowercase, letters and digits only |

For TV, put your playlist's URL (plain `http://`) in `/data/local/companion-clock/m3u.url`, also `chmod 600`.

## 3. Start at boot

```bash
adb push device/boot.sh /data/local/tmp/
adb shell 'su -c "cp /data/local/tmp/boot.sh /data/adb/service.d/companion-clock.sh; chmod 755 /data/adb/service.d/companion-clock.sh"'
```

Magisk runs `service.d` scripts at boot with its own BusyBox, from `/data/adb/magisk`. If that folder is empty, scripts never run: Magisk logs `Magisk environment incomplete, abort` in `/cache/magisk.log`. Fill it from the Magisk APK of the same version (`lib/<abi>/lib*.so` → `busybox`, `magisk32`, `magiskboot`, `magiskinit`, `magiskpolicy`, plus `assets/*.sh` and `stub.apk`).

Optional: ADB over Wi-Fi, firewalled to one computer. Write that computer's IP to `/data/local/companion-clock/adb_from` and the boot script opens port 5555 to it only.

## 4. Deploy the calendar

1. Open [script.google.com](https://script.google.com) with the Google account whose calendar you want, and create a project.
2. Paste [`calendar/Code.gs`](../calendar/Code.gs) and set `KEY` to a long random string (`openssl rand -hex 18`).
3. **Deploy → New deployment → Web app**, Execute as **Me**, Who has access **Anyone**. Authorise it.
4. Put the web app URL plus `?k=<KEY>` in `calendarUrl`.

To change the script later, edit it, then **Deploy → Manage deployments → Edit → New version**: the URL stays the same.

## 5. Point Fully at it

In Fully Kiosk Browser, set the Start URL to `http://localhost:8080/` and turn on kiosk mode. Keep "JavaScript Interface" off.

## Update

```bash
adb push index.html /data/local/tmp/
adb shell 'su -c "mv /data/local/tmp/index.html /data/local/companion-clock/index.html; chmod 644 /data/local/companion-clock/index.html"'
adb shell am start -n de.ozerov.fully/.MainActivity -a android.intent.action.VIEW -d http://localhost:8080/
```
