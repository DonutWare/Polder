import "dart:convert";

import "package:drift/drift.dart";
import "package:flutter/material.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder_calendar/polder_calendar.dart";

enum CachedEventState { synced, pending, deleted }

class CachedEvent {
  const CachedEvent(this.event, this.state);

  final CalendarEvent event;
  final CachedEventState state;

  String get key => CalendarCache.keyOf(event.ref);
}

class CalendarCache {
  CalendarCache(this._db);

  final OfflineDatabase _db;

  static String keyOf(EventRef ref) => "${seriesKeyOf(ref)}/${ref.recurrenceId ?? ""}";

  static String seriesKeyOf(EventRef ref) => "${ref.calendar.calendarId}/${ref.eventId}";

  static String monthOf(DateTime moment) => "${moment.year}-${moment.month.toString().padLeft(2, "0")}";

  Future<List<CachedEvent>> overlapping(DateTimeRange range, {Set<String>? calendarIds}) async {
    final rows = await _db
        .customSelect(
          "SELECT state, json FROM calendar_events WHERE start_ms < ? AND end_ms > ?",
          variables: [Variable.withInt(_ms(range.end)), Variable.withInt(_ms(range.start))],
        )
        .get();
    return [
      for (final cached in rows.map(_fromRow))
        if (calendarIds == null || calendarIds.contains(cached.event.calendar.calendarId)) cached,
    ];
  }

  Future<CachedEvent?> event(String key) async {
    final row = await _db
        .customSelect("SELECT state, json FROM calendar_events WHERE key = ?", variables: [Variable.withString(key)])
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<CachedEvent>> series(EventRef ref) async {
    final rows = await _db
        .customSelect(
          "SELECT state, json FROM calendar_events WHERE series_key = ?",
          variables: [Variable.withString(seriesKeyOf(ref))],
        )
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<void> save(CalendarEvent event, CachedEventState state) => _db.customInsert(
    """
    INSERT OR REPLACE INTO calendar_events (key, series_key, calendar_id, start_ms, end_ms, state, json)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """,
    variables: [
      Variable.withString(keyOf(event.ref)),
      Variable.withString(seriesKeyOf(event.ref)),
      Variable.withString(event.calendar.calendarId),
      Variable.withInt(_ms(event.start)),
      Variable.withInt(_ms(event.end.isAfter(event.start) ? event.end : event.start.add(const Duration(minutes: 1)))),
      Variable.withString(state.name),
      Variable.withString(jsonEncode(CalendarCodec.event(event))),
    ],
  );

  Future<void> remove(String key) =>
      _db.customUpdate("DELETE FROM calendar_events WHERE key = ?", variables: [Variable.withString(key)]);

  Future<void> removeSeries(EventRef ref) => _db.customUpdate(
    "DELETE FROM calendar_events WHERE series_key = ?",
    variables: [Variable.withString(seriesKeyOf(ref))],
  );

  Future<void> forgetLocalChanges(EventRef ref) => _db.customUpdate(
    "DELETE FROM calendar_events WHERE series_key = ? AND state != 'synced'",
    variables: [Variable.withString(seriesKeyOf(ref))],
  );

  Future<void> replaceFromServer(DateTimeRange range, List<CalendarEvent> events, {Set<String>? calendarIds}) =>
      _db.transaction(() async {
        for (final cached in await overlapping(range, calendarIds: calendarIds)) {
          if (cached.state == CachedEventState.synced) await remove(cached.key);
        }
        final local = {
          for (final cached in await overlapping(range, calendarIds: calendarIds))
            if (cached.state != CachedEventState.synced) CalendarCache.seriesKeyOf(cached.event.ref),
        };
        for (final event in events) {
          if (!local.contains(seriesKeyOf(event.ref))) await save(event, CachedEventState.synced);
        }
        if (calendarIds == null) await _markFetched(range);
      });

  Future<bool> covers(DateTimeRange range) async {
    final fetched = {
      for (final row in await _db.customSelect("SELECT month FROM calendar_months").get()) row.read<String>("month"),
    };
    return _monthsIn(range).every(fetched.contains);
  }

  Future<void> _markFetched(DateTimeRange range) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final month in _monthsIn(range)) {
      await _db.customInsert(
        "INSERT OR REPLACE INTO calendar_months (month, fetched_ms) VALUES (?, ?)",
        variables: [Variable.withString(month), Variable.withInt(now)],
      );
    }
  }

  static Iterable<String> _monthsIn(DateTimeRange range) sync* {
    var month = DateTime(range.start.year, range.start.month);
    while (month.isBefore(range.end)) {
      yield monthOf(month);
      month = DateTime(month.year, month.month + 1);
    }
  }

  static int _ms(DateTime moment) => moment.millisecondsSinceEpoch;

  static CachedEvent _fromRow(QueryRow row) => CachedEvent(
    CalendarCodec.eventFrom(jsonDecode(row.read<String>("json")) as Map<String, dynamic>),
    CachedEventState.values.byName(row.read<String>("state")),
  );
}

abstract final class CalendarCodec {
  static Map<String, dynamic> calendarRef(CalendarRef ref) => {"source": ref.sourceId, "calendar": ref.calendarId};

  static CalendarRef calendarRefFrom(Map<String, dynamic> json) =>
      CalendarRef(sourceId: json["source"] as String, calendarId: json["calendar"] as String);

  static Map<String, dynamic> eventRef(EventRef ref) => {
    "calendar": calendarRef(ref.calendar),
    "event": ref.eventId,
    "recurrence": ?ref.recurrenceId,
  };

  static EventRef eventRefFrom(Map<String, dynamic> json) => EventRef(
    calendar: calendarRefFrom(json["calendar"] as Map<String, dynamic>),
    eventId: json["event"] as String,
    recurrenceId: json["recurrence"] as String?,
  );

  static Map<String, dynamic> person(EventPerson person) => {
    "email": person.email,
    "name": ?person.name,
    "self": person.self,
  };

  static EventPerson personFrom(Map<String, dynamic> json) =>
      EventPerson(email: json["email"] as String, name: json["name"] as String?, self: json["self"] as bool? ?? false);

  static Map<String, dynamic> reminder(EventReminder reminder) => {
    "action": reminder.action.name,
    "offset": ?reminder.offsetMinutes,
    "relativeToEnd": reminder.relativeToEnd,
    "at": ?reminder.at?.toUtc().toIso8601String(),
  };

  static EventReminder reminderFrom(Map<String, dynamic> json) => EventReminder(
    action: ReminderAction.values.byName(json["action"] as String),
    offsetMinutes: json["offset"] as int?,
    relativeToEnd: json["relativeToEnd"] as bool? ?? false,
    at: _date(json["at"])?.toLocal(),
  );

  static Map<String, dynamic> event(CalendarEvent event) => {
    "ref": eventRef(event.ref),
    "etag": event.etag,
    "summary": event.summary,
    "start": _moment(event.start, event.allDay),
    "end": _moment(event.end, event.allDay),
    "allDay": event.allDay,
    "description": ?event.description,
    "location": ?event.location,
    "url": ?event.url,
    "timezone": ?event.timezone,
    "rrule": ?event.rrule,
    "recurring": event.recurring,
    "modifiedOccurrence": event.modifiedOccurrence,
    "status": event.status.name,
    "showAs": event.showAs.name,
    "busyOnly": event.busyOnly,
    "organizer": ?(event.organizer == null ? null : person(event.organizer!)),
    "attendees": [
      for (final attendee in event.attendees)
        {"person": person(attendee.person), "status": attendee.status.name, "role": attendee.role.name},
    ],
    "reminders": [for (final item in event.reminders) reminder(item)],
  };

  static CalendarEvent eventFrom(Map<String, dynamic> json) {
    final allDay = json["allDay"] as bool? ?? false;
    return CalendarEvent(
      ref: eventRefFrom(json["ref"] as Map<String, dynamic>),
      etag: json["etag"] as String? ?? "",
      summary: json["summary"] as String? ?? "",
      start: _momentFrom(json["start"], allDay),
      end: _momentFrom(json["end"], allDay),
      allDay: allDay,
      description: json["description"] as String?,
      location: json["location"] as String?,
      url: json["url"] as String?,
      timezone: json["timezone"] as String?,
      rrule: json["rrule"] as String?,
      recurring: json["recurring"] as bool? ?? false,
      modifiedOccurrence: json["modifiedOccurrence"] as bool? ?? false,
      status: EventStatus.values.byName(json["status"] as String? ?? EventStatus.confirmed.name),
      showAs: EventShowAs.values.byName(json["showAs"] as String? ?? EventShowAs.busy.name),
      busyOnly: json["busyOnly"] as bool? ?? false,
      organizer: switch (json["organizer"]) {
        final Map<String, dynamic> organizer => personFrom(organizer),
        _ => null,
      },
      attendees: [
        for (final attendee in (json["attendees"] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
          EventAttendee(
            person: personFrom(attendee["person"] as Map<String, dynamic>),
            status: AttendeeStatus.values.byName(attendee["status"] as String),
            role: AttendeeRole.values.byName(attendee["role"] as String),
          ),
      ],
      reminders: [
        for (final item in (json["reminders"] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
          reminderFrom(item),
      ],
    );
  }

  static Map<String, dynamic> draft(EventDraft draft) => {
    "summary": draft.summary,
    "start": _moment(draft.start, draft.allDay),
    "end": _moment(draft.end, draft.allDay),
    "allDay": draft.allDay,
    "description": ?draft.description,
    "location": ?draft.location,
    "url": ?draft.url,
    "timezone": ?draft.timezone,
    "rrule": ?draft.rrule,
    "status": draft.status.name,
    "showAs": draft.showAs.name,
    "attendees": [for (final attendee in draft.attendees) person(attendee)],
    "reminders": [for (final item in draft.reminders) reminder(item)],
  };

  static EventDraft draftFrom(Map<String, dynamic> json) {
    final allDay = json["allDay"] as bool? ?? false;
    return EventDraft(
      summary: json["summary"] as String? ?? "",
      start: _momentFrom(json["start"], allDay),
      end: _momentFrom(json["end"], allDay),
      allDay: allDay,
      description: json["description"] as String?,
      location: json["location"] as String?,
      url: json["url"] as String?,
      timezone: json["timezone"] as String?,
      rrule: json["rrule"] as String?,
      status: EventStatus.values.byName(json["status"] as String? ?? EventStatus.confirmed.name),
      showAs: EventShowAs.values.byName(json["showAs"] as String? ?? EventShowAs.busy.name),
      attendees: [
        for (final attendee in (json["attendees"] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
          personFrom(attendee),
      ],
      reminders: [
        for (final item in (json["reminders"] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
          reminderFrom(item),
      ],
    );
  }

  static Map<String, dynamic> info(CalendarInfo info) => {
    "ref": calendarRef(info.ref),
    "name": info.name,
    "color": ?info.color?.toARGB32(),
    "access": info.access.name,
    "hidden": info.hidden,
    "notify": info.notify,
    "isDefault": info.isDefault,
    "subscription": info.subscription,
    "ownerName": ?info.ownerName,
    "sourceUrl": ?info.sourceUrl,
    "fetchedAt": ?info.fetchedAt?.toUtc().toIso8601String(),
    "fetchError": ?info.fetchError,
  };

  static CalendarInfo infoFrom(Map<String, dynamic> json) => CalendarInfo(
    ref: calendarRefFrom(json["ref"] as Map<String, dynamic>),
    name: json["name"] as String? ?? "",
    color: switch (json["color"]) {
      final int argb => Color(argb),
      _ => null,
    },
    access: CalendarAccess.values.byName(json["access"] as String),
    hidden: json["hidden"] as bool? ?? false,
    notify: json["notify"] as bool? ?? true,
    isDefault: json["isDefault"] as bool? ?? false,
    subscription: json["subscription"] as bool? ?? false,
    ownerName: json["ownerName"] as String?,
    sourceUrl: json["sourceUrl"] as String?,
    fetchedAt: _date(json["fetchedAt"])?.toLocal(),
    fetchError: json["fetchError"] as String?,
  );

  static String _moment(DateTime value, bool allDay) =>
      allDay ? DateTime(value.year, value.month, value.day).toIso8601String() : value.toUtc().toIso8601String();

  static DateTime _momentFrom(Object? value, bool allDay) {
    final parsed = DateTime.parse(value! as String);
    return allDay ? DateTime(parsed.year, parsed.month, parsed.day) : parsed.toLocal();
  }

  static DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
