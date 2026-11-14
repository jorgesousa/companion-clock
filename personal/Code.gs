// Companion Clock: your personal Google Calendar as JSON (PERSONAL mode).
//   ?f=calendar&k=<KEY>   same shape as the work feed
// Football doesn't come through here: the clock reads ESPN's public API directly.
//
// Deploy as a web app in your personal Google account:
//   Deploy → New deployment → Web app · Execute as: Me · Who has access: Anyone
// Run `authorize` once from the editor: it grants Calendar access and creates the KEY,
// which it prints in the execution log. Put in the clock's config.json:
//   "personalCalUrl": "<web app URL>?f=calendar&k=<KEY>"

var DAYS = 15; // today → end of next week

function doGet(e) {
  var p = (e && e.parameter) || {};
  if (p.f === 'calendar' && p.k && p.k === key()) return json(calendar());
  return json({ error: 'forbidden' });
}

function key() { return PropertiesService.getScriptProperties().getProperty('KEY'); }

function calendar() {
  var start = new Date(); start.setHours(0, 0, 0, 0);
  var end = new Date(start.getTime() + DAYS * 24 * 60 * 60 * 1000);
  return CalendarApp.getDefaultCalendar().getEvents(start, end)
    .filter(function (ev) { return ev.getMyStatus() !== CalendarApp.GuestStatus.NO; })
    .map(function (ev) {
      return {
        start: ev.getStartTime().toISOString(), end: ev.getEndTime().toISOString(),
        title: ev.getTitle(), allDay: ev.isAllDayEvent(),
        type: ev.getEventType ? String(ev.getEventType()) : 'DEFAULT'
      };
    });
}

// Run once from the editor: grants Calendar access and creates the KEY.
function authorize() {
  CalendarApp.getDefaultCalendar().getName();
  var props = PropertiesService.getScriptProperties();
  if (!props.getProperty('KEY')) props.setProperty('KEY', Utilities.getUuid().replace(/-/g, ''));
  Logger.log('Calendar key: ' + props.getProperty('KEY'));
}

function json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
