#!/system/bin/sh
C=/data/local/companion-clock
log(){ echo "$(date '+%F %T') $*" >> $C/boot.log; }
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
log "boot completed"

# ADB over Wi-Fi (port 5555), only from the Mac's IP (ro.adb.secure=0: no key check, so firewall it)
ADB_FROM=$(cat $C/adb_from 2>/dev/null)
if [ -n "$ADB_FROM" ]; then
  iptables -D INPUT -p tcp --dport 5555 -j DROP 2>/dev/null
  iptables -D INPUT -p tcp --dport 5555 -s "$ADB_FROM" -j ACCEPT 2>/dev/null
  iptables -I INPUT -p tcp --dport 5555 -j DROP
  iptables -I INPUT -p tcp --dport 5555 -s "$ADB_FROM" -j ACCEPT
  if [ "$(getprop service.adb.tcp.port)" != "5555" ]; then
    setprop service.adb.tcp.port 5555; stop adbd; start adbd
  fi
  log "adb wifi on, allowed from $ADB_FROM"
fi

server(){
  pkill -f 'nc -L -s 127.0.0.1 -p 8080' 2>/dev/null
  # toybox nc (Magisk runs this with busybox, whose nc lacks -L)
  nohup /system/bin/nc -L -s 127.0.0.1 -p 8080 /system/bin/sh $C/serve.sh >/dev/null 2>&1 &
}
up(){ pgrep -f 'nc -L -s 127.0.0.1 -p 8080' >/dev/null; }
server; sleep 5
up && log "server up" || log "server failed to start"

[ -f $C/watchdog.pid ] && kill "$(cat $C/watchdog.pid)" 2>/dev/null
irq(){ grep tlsc6x /proc/interrupts | tr -s ' ' | cut -d' ' -f3; }
(
  prev=$(irq)
  while true; do
    # keep the local server alive; reload the page after a restart
    if ! up; then
      log "server down - restarting"; server; sleep 3
      am start -n de.ozerov.fully/.MainActivity -a android.intent.action.VIEW -d http://localhost:8080/ >/dev/null 2>&1
    fi
    if [ ! -f $C/pause ] && ! dumpsys activity activities | grep -m1 mResumedActivity | grep -q de.ozerov.fully; then
      am start -n de.ozerov.fully/.MainActivity >/dev/null 2>&1
    fi
    cur=$(irq); d=$((cur - prev)); prev=$cur
    if [ "$d" -gt 250 ]; then
      # ghost touch: the panel keeps reporting a touch with no finger on it.
      # Two shapes seen: stuck on the top edge (Y<=8), or glued to one exact point.
      last=$(dmesg | grep 'pointer report' | tail -60 | sed 's/.*X is \([0-9]*\), Y is \([0-9]*\),.*/\1 \2/')
      edge=$(echo "$last" | awk '$2>8{c++} END{print c+0}')
      pts=$(echo "$last" | sort -u | wc -l)
      if [ "$edge" -eq 0 ] || [ "$pts" -le 1 ]; then
        echo "$(date) ghost touch ($d irq/5s, $pts point(s)) - reset" >> $C/touch.log
        input keyevent 223; sleep 2; input keyevent 224; sleep 2; prev=$(irq)
      fi
    fi
    sleep 5
  done
) >/dev/null 2>&1 &
echo $! > $C/watchdog.pid
log "watchdog $!"
