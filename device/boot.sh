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

# touch filter: drops a touch stuck on the top edge before Android sees it (device/tpfilter.c); restarted if it stops
[ -f $C/tpfilter.pid ] && kill "$(cat $C/tpfilter.pid)" 2>/dev/null; pkill -x tpfilter 2>/dev/null
if [ -x $C/tpfilter ]; then
  ( while true; do $C/tpfilter >> $C/tpfilter.log 2>&1; sleep 5; done ) >/dev/null 2>&1 &
  echo $! > $C/tpfilter.pid; log "touch filter $!"
fi

[ -f $C/watchdog.pid ] && kill "$(cat $C/watchdog.pid)" 2>/dev/null
irq(){ grep tlsc6x /proc/interrupts | tr -s ' ' | cut -d' ' -f3; }
(
  n=0; sus=0; prev=$(irq); lr=0; gap=0
  while true; do
    # keep the local server alive; reload the page after a restart
    if ! up; then
      log "server down - restarting"; server; sleep 3
      am start -n de.ozerov.fully/.MainActivity -a android.intent.action.VIEW -d http://localhost:8080/ >/dev/null 2>&1
    fi
    n=$((n + 1))
    # keep Fully in front (every ~6 s; dumpsys is heavy on this device)
    if [ $((n % 3)) -eq 0 ] && [ ! -f $C/pause ] && ! dumpsys activity activities | grep -m1 mResumedActivity | grep -q de.ozerov.fully; then
      am start -n de.ozerov.fully/.MainActivity >/dev/null 2>&1
    fi
    cur=$(irq); d=$((cur - prev)); prev=$cur
    if [ "$d" -gt 100 ]; then
      # ghost touch: the panel keeps reporting a touch with no finger on it.
      # Two shapes seen: stuck near the top edge (Y<=24), or glued to one exact point.
      last=$(dmesg | grep 'pointer report' | tail -60 | sed 's/.*X is \([0-9]*\), Y is \([0-9]*\),.*/\1 \2/')
      edge=$(echo "$last" | awk '$2>24{c++} END{print c+0}')
      pts=$(echo "$last" | sort -u | wc -l)
      # two stuck checks in a row (~4 s), so a finger held still on a stepper isn't mistaken for one
      if [ "$edge" -eq 0 ] || [ "$pts" -le 1 ]; then sus=$((sus + 1)); else sus=0; fi
      # a panel that keeps sticking (damp, pressure on the edge) would blink the screen every few seconds:
      # while it keeps coming back within 10 min of a reset, wait longer between resets (2, 4, 8, then 20 min at most)
      # the touch filter hides a stuck touch from Android, but while stuck the panel loses real fingers (a press
      # arrives, its moves and lift don't), so the panel still needs the reset
      now=$(date +%s)
      if [ "$sus" -ge 2 ] && [ $((now - lr)) -lt "$gap" ]; then sus=0; fi
      if [ "$sus" -ge 2 ]; then
        sus=0
        if [ $((now - lr)) -lt $((gap + 600)) ]; then gap=$((gap * 2)); [ "$gap" -lt 120 ] && gap=120; [ "$gap" -gt 1200 ] && gap=1200; else gap=0; fi
        lr=$now
        # sleep/wake resets the panel (the screen blinks for ~2 s). Don't unbind/bind the tlsc6x driver instead:
        # it leaves a dangling tlsc6x_wakelock in the kernel, the next read of the wakelock list hangs
        # system_server, and the hardware watchdog reboots the clock (wdt_hw), minutes later.
        echo "$(date) ghost touch ($d irq/2s, $pts point(s)) - sleep/wake" >> $C/touch.log
        input keyevent 223; sleep 2; input keyevent 224; sleep 2
        prev=$(irq)
      fi
    else
      sus=0
    fi
    sleep 2
  done
) >/dev/null 2>&1 &
echo $! > $C/watchdog.pid
log "watchdog $!"
