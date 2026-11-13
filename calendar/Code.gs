// Companion Clock: calendar feed as JSON (read-only).
//
// Deploy as a web app in your own Google account:
//   Deploy → New deployment → Web app · Execute as: Me · Who has access: Anyone
// Then put the web app URL, with ?k=<KEY>, in the clock's config.json as "calendarUrl".
// KEY is a long random string only you and the clock know; generate one with:
//   openssl rand -hex 18

var KEY = 'replace-with-a-long-random-string';
var DAYS = 15; // today → end of next week, whatever weekday it is

function doGet(e) {
  if (!e || !e.parameter || e.parameter.k !== KEY) {
    return json({ error: 'forbidden' });
  }
  var start = new Date(); start.setHours(0, 0, 0, 0);
  var end = new Date(start.getTime() + DAYS * 24 * 60 * 60 * 1000);
  var events = CalendarApp.getDefaultCalendar().getEvents(start, end)
    // declined meetings are left out
    .filter(function (ev) { return ev.getMyStatus() !== CalendarApp.GuestStatus.NO; })
    .map(function (ev) {
      return {
        start: ev.getStartTime().toISOString(),
        end: ev.getEndTime().toISOString(),
        title: ev.getTitle(),
        allDay: ev.isAllDayEvent(),
        // WORKING_LOCATION events (Home / Office) become the day's location, not a row
        type: ev.getEventType ? String(ev.getEventType()) : 'DEFAULT'
      };
    });
  return json(events);
}

function json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
