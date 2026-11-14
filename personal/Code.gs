// Companion Clock: the personal side (PERSONAL mode) as JSON.
//   ?f=football&teams=<ids>&ft=<token>  recent and upcoming matches (football-data.org v4)
//   ?f=table&comp=PPL&ft=<token>        league table
//   ?f=calendar&k=<KEY>                 your personal Google Calendar (same shape as the work feed)
//
// Deploy as a web app in your personal Google account:
//   Deploy → New deployment → Web app · Execute as: Me · Who has access: Anyone
// Run `authorize` once from the editor: it grants access (external sites, Calendar) and creates
// the calendar KEY, which it prints in the execution log. Put in the clock's config.json:
//   "footballUrl": "<web app URL>", "footballToken": "<football-data.org token>",
//   "personalCalUrl": "<web app URL>?f=calendar&k=<KEY>"
// The football token is never stored here; the clock sends it with each call.

var DAYS = 15; // today → end of next week

function doGet(e) {
  var p = (e && e.parameter) || {};
  if (p.f === 'calendar') return json(p.k && p.k === key() ? calendar() : { error: 'forbidden' });
  if (p.f === 'table') return json(table(p.comp || 'PPL', p.ft));
  return json(football(p.teams, p.ft));
}

function key() { return PropertiesService.getScriptProperties().getProperty('KEY'); }

function api(path, token) {
  var r = UrlFetchApp.fetch('https://api.football-data.org/v4/' + path, { headers: { 'X-Auth-Token': token }, muteHttpExceptions: true });
  return { code: r.getResponseCode(), body: r.getResponseCode() === 200 ? JSON.parse(r.getContentText()) : null };
}

// Recent and upcoming matches for each team. Cached 10 min, 1 min while one is live (free tier: 10 calls/min).
function football(teams, token) {
  if (!teams || !token) return { error: 'missing teams or token' };
  var ids = String(teams).split(',').filter(function (x) { return /^\d+$/.test(x); }).slice(0, 4);
  var cache = CacheService.getScriptCache(), ck = 'fb:' + ids.join(','), hit = cache.get(ck);
  if (hit) return JSON.parse(hit);
  var day = 24 * 60 * 60 * 1000, now = Date.now(), live = false;
  var from = Utilities.formatDate(new Date(now - 10 * day), 'UTC', 'yyyy-MM-dd');
  var to = Utilities.formatDate(new Date(now + 30 * day), 'UTC', 'yyyy-MM-dd');
  var out = ids.map(function (id) {
    var r = api('teams/' + id + '/matches?dateFrom=' + from + '&dateTo=' + to, token);
    if (!r.body) return { team: +id, error: r.code };
    return {
      team: +id,
      matches: (r.body.matches || []).map(function (m) {
        if (m.status === 'IN_PLAY' || m.status === 'PAUSED') live = true;
        return {
          utc: m.utcDate, status: m.status, comp: m.competition && m.competition.name,
          home: m.homeTeam.shortName || m.homeTeam.name, homeId: m.homeTeam.id,
          away: m.awayTeam.shortName || m.awayTeam.name, awayId: m.awayTeam.id,
          score: m.score && m.score.fullTime ? [m.score.fullTime.home, m.score.fullTime.away] : null
        };
      })
    };
  });
  cache.put(ck, JSON.stringify(out), live ? 60 : 600);
  return out;
}

// League table (overall), cached 30 min.
function table(comp, token) {
  if (!token || !/^[A-Z0-9]{2,4}$/.test(comp)) return { error: 'missing token or competition' };
  var cache = CacheService.getScriptCache(), ck = 'tb:' + comp, hit = cache.get(ck);
  if (hit) return JSON.parse(hit);
  var r = api('competitions/' + comp + '/standings', token);
  if (!r.body) return { error: r.code };
  var total = (r.body.standings || []).filter(function (s) { return s.type === 'TOTAL'; })[0] || { table: [] };
  var out = total.table.map(function (t) {
    return { pos: t.position, teamId: t.team.id, team: t.team.shortName || t.team.name, pts: t.points, played: t.playedGames };
  });
  cache.put(ck, JSON.stringify(out), 1800);
  return out;
}

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

// Run once from the editor: grants access (external sites, Calendar) and creates the calendar KEY.
function authorize() {
  UrlFetchApp.fetch('https://api.football-data.org/v4/areas/2187', { muteHttpExceptions: true });
  CalendarApp.getDefaultCalendar().getName();
  var props = PropertiesService.getScriptProperties();
  if (!props.getProperty('KEY')) props.setProperty('KEY', Utilities.getUuid().replace(/-/g, ''));
  Logger.log('Calendar key: ' + props.getProperty('KEY'));
}

function json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
