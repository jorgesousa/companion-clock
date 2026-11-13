#!/system/bin/sh
D=/data/local/companion-clock
nf(){ printf 'HTTP/1.0 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n'; exit 0; }
read -r m p v
p0=$p
p=${p%%\?*}
while read -r h && [ "${h%$(printf '\r')}" != "" ]; do :; done
case "$p" in
  /|/index.html) f=$D/index.html; t=text/html;;
  /config.json) f=$D/config.json; t=application/json;;
  /a/*)
    n=${p#/a/}; case "$n" in *[!A-Za-z0-9.-]*|.*|'') nf;; esac
    f=$D/assets/$n
    case "$n" in *.woff2) t=font/woff2;; *.css) t=text/css;; *.js) t=application/javascript;; *) nf;; esac;;
  /bright)
    q=${p0#*\?}; n=${q#v=}; case "$n" in ''|*[!0-9]*) nf;; esac
    [ "$n" -gt 255 ] && n=255
    settings put system screen_brightness_mode 0; settings put system screen_brightness "$n"
    printf 'HTTP/1.0 204 No Content\r\nConnection: close\r\n\r\n'; exit 0;;
  /playlist.m3u)
    f=$D/playlist.cache; t=audio/x-mpegurl
    age=99999; [ -s "$f" ] && age=$(( $(date +%s) - $(stat -c %Y "$f") ))
    if [ "$age" -gt 21600 ] && [ -s $D/m3u.url ]; then
      U=$(cat $D/m3u.url); U=${U#http://}; hp=${U%%/*}; path=/${U#*/}
      host=${hp%%:*}; port=${hp#*:}; [ "$port" = "$hp" ] && port=80
      (printf 'GET %s HTTP/1.0\r\nHost: %s\r\nUser-Agent: Mozilla/5.0\r\nConnection: close\r\n\r\n' "$path" "$hp"; sleep 12) | nc -w 15 "$host" "$port" > $D/playlist.raw 2>/dev/null
      if head -1 $D/playlist.raw | grep -q ' 200'; then tr -d '\r' < $D/playlist.raw | sed '1,/^$/d' > $D/playlist.new && [ -s $D/playlist.new ] && mv $D/playlist.new "$f"; fi
      rm -f $D/playlist.raw $D/playlist.new
    fi;;
  *) nf;;
esac
[ -s "$f" ] || nf
cc=no-cache; case "$p" in /a/*) cc="max-age=31536000";; esac
printf 'HTTP/1.0 200 OK\r\nContent-Type: %s; charset=utf-8\r\nContent-Length: %s\r\nCache-Control: %s\r\nConnection: close\r\n\r\n' "$t" "$(wc -c < "$f" | tr -d ' ')" "$cc"
cat "$f"
