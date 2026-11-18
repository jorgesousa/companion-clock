// tpfilter: sits between the touch panel (mtk-tpd) and Android and drops touches the panel makes up.
// The panel sometimes reports a finger stuck in one place with nothing there; Android holds it as a
// pressed finger and real taps stop working. Two rules:
//  - a touch that starts near the top edge (Y <= EDGE) is ignored: the stuck point has been there;
//  - a touch that hasn't moved at all for STILL_MS is released and ignored until it lifts: a real
//    finger always moves a little.
// It grabs the panel (so Android no longer reads it) and re-sends every other touch through a
// virtual touchscreen (/dev/uinput). If it exits, the grab is released and the panel goes straight
// back to Android. Build: device/build-tpfilter.sh. Runs as root from boot.sh.
#include <fcntl.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <poll.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define EDGE 24
#define STILL_MS 4000
#define SLOTS 10

struct slot { int id, x, y, blocked, shown, sx, sy, began; long moved; };
static struct slot s[SLOTS];
static int ufd, nextid = 1, touching = 0, osl = -1;

static long ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000L + t.tv_nsec / 1000000; }

static void emit(int type, int code, int value) {
  struct input_event e; memset(&e, 0, sizeof e);
  e.type = type; e.code = code; e.value = value;
  if (write(ufd, &e, sizeof e) < 0) {}
}
static void slot_sel(int i) { if (osl != i) { emit(EV_ABS, ABS_MT_SLOT, i); osl = i; } }

// send Android what changed since the last frame
static void flush(void) {
  long now = ms();
  int any = 0, fx = 0, fy = 0, out = 0;
  for (int i = 0; i < SLOTS; i++) {
    struct slot *p = &s[i];
    if (p->began) { p->blocked = p->y <= EDGE; p->began = 0; p->moved = now; }
    if (p->id >= 0 && !p->blocked && now - p->moved >= STILL_MS) p->blocked = 1;
    int vis = p->id >= 0 && !p->blocked;
    if (vis && !p->shown) {
      slot_sel(i);
      emit(EV_ABS, ABS_MT_TRACKING_ID, nextid++ & 0xffff);
      emit(EV_ABS, ABS_MT_POSITION_X, p->x); emit(EV_ABS, ABS_MT_POSITION_Y, p->y);
      p->sx = p->x; p->sy = p->y; p->shown = 1; out = 1;
    } else if (vis && (p->x != p->sx || p->y != p->sy)) {
      slot_sel(i);
      if (p->x != p->sx) emit(EV_ABS, ABS_MT_POSITION_X, p->x);
      if (p->y != p->sy) emit(EV_ABS, ABS_MT_POSITION_Y, p->y);
      p->sx = p->x; p->sy = p->y; out = 1;
    } else if (!vis && p->shown) {
      slot_sel(i);
      emit(EV_ABS, ABS_MT_TRACKING_ID, -1); p->shown = 0; out = 1;
    }
    if (vis && !any) { any = 1; fx = p->x; fy = p->y; }
  }
  if (any != touching) { emit(EV_KEY, BTN_TOUCH, any); touching = any; out = 1; }
  if (out) { if (any) { emit(EV_ABS, ABS_X, fx); emit(EV_ABS, ABS_Y, fy); } emit(EV_SYN, SYN_REPORT, 0); }
}

static int open_panel(void) {
  char path[32], name[64];
  for (int i = 0; i < 16; i++) {
    snprintf(path, sizeof path, "/dev/input/event%d", i);
    int fd = open(path, O_RDONLY);
    if (fd < 0) continue;
    name[0] = 0; ioctl(fd, EVIOCGNAME(sizeof name), name);
    if (!strcmp(name, "mtk-tpd")) return fd;
    close(fd);
  }
  return -1;
}

int main(void) {
  int fd = open_panel();
  if (fd < 0) { fprintf(stderr, "tpfilter: mtk-tpd not found\n"); return 1; }
  ufd = open("/dev/uinput", O_WRONLY);
  if (ufd < 0) { perror("tpfilter: /dev/uinput"); return 1; }

  struct uinput_user_dev u; memset(&u, 0, sizeof u);
  snprintf(u.name, sizeof u.name, "tpfilter");
  u.id.bustype = BUS_VIRTUAL; u.id.vendor = 0x1; u.id.product = 0x1; u.id.version = 1;
  int axes[] = { ABS_X, ABS_Y, ABS_MT_SLOT, ABS_MT_TRACKING_ID, ABS_MT_POSITION_X, ABS_MT_POSITION_Y };
  ioctl(ufd, UI_SET_EVBIT, EV_KEY); ioctl(ufd, UI_SET_KEYBIT, BTN_TOUCH);
  ioctl(ufd, UI_SET_EVBIT, EV_ABS);
  ioctl(ufd, UI_SET_PROPBIT, INPUT_PROP_DIRECT);
  for (unsigned i = 0; i < sizeof axes / sizeof *axes; i++) {
    struct input_absinfo a; memset(&a, 0, sizeof a);
    ioctl(fd, EVIOCGABS(axes[i]), &a);
    ioctl(ufd, UI_SET_ABSBIT, axes[i]);
    u.absmin[axes[i]] = a.minimum; u.absmax[axes[i]] = a.maximum;
  }
  u.absmax[ABS_MT_SLOT] = SLOTS - 1; u.absmin[ABS_MT_TRACKING_ID] = 0; u.absmax[ABS_MT_TRACKING_ID] = 65535;
  if (write(ufd, &u, sizeof u) < 0 || ioctl(ufd, UI_DEV_CREATE) < 0) { perror("tpfilter: create"); return 1; }
  usleep(300000);
  if (ioctl(fd, EVIOCGRAB, 1) < 0) { perror("tpfilter: grab"); return 1; }

  memset(s, 0, sizeof s);
  for (int i = 0; i < SLOTS; i++) s[i].id = -1;
  int cur = 0;
  struct input_event ev[64];
  struct pollfd pf = { fd, POLLIN, 0 };
  for (;;) {
    // wake at least every 250 ms so a touch that stopped moving gets released on time
    if (poll(&pf, 1, 250) <= 0) { flush(); continue; }
    ssize_t n = read(fd, ev, sizeof ev);
    if (n <= 0) return 2; // panel gone: exit, boot.sh starts us again
    for (int k = 0; k < (int)(n / sizeof *ev); k++) {
      struct input_event *e = &ev[k];
      struct slot *p = &s[cur];
      if (e->type == EV_ABS) {
        if (e->code == ABS_MT_SLOT) cur = (e->value >= 0 && e->value < SLOTS) ? e->value : 0;
        else if (e->code == ABS_MT_TRACKING_ID) {
          if (e->value < 0) p->id = -1; else if (p->id != e->value) { p->id = e->value; p->began = 1; }
        }
        else if (e->code == ABS_MT_POSITION_X) { if (p->x != e->value) p->moved = ms(); p->x = e->value; }
        else if (e->code == ABS_MT_POSITION_Y) { if (p->y != e->value) p->moved = ms(); p->y = e->value; }
      } else if (e->type == EV_SYN && e->code == SYN_REPORT) flush();
    }
  }
}
