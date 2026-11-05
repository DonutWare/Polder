import "package:flutter/material.dart";

import "package:polder/services/api/polder_api.dart";
import "package:polder_calendar/polder_calendar.dart";

class PolderCalendarSource implements CalendarSource {
  PolderCalendarSource(this._api, {required this.id, required this.label, required this.changes});

  final PolderApi _api;

  @override
  final String id;

  @override
  final String label;

  @override
  final Stream<CalendarRef> changes;

  @override
  CalendarCapabilities get capabilities => const CalendarCapabilities(
    canCreate: true,
    canEdit: true,
    recurrenceScopes: true,
    rsvp: true,
    moveBetweenCalendars: true,
  );

  @override
  Future<List<CalendarInfo>> calendars() => _api.calendarInfos(id);

  @override
  Future<List<CalendarEvent>> events(DateTimeRange range, {Set<CalendarRef>? calendars}) => _api.calendarEvents(
    id,
    range,
    calendarIds: calendars == null ? null : [for (final calendar in calendars) int.parse(calendar.calendarId)],
  );

  @override
  Future<CalendarEventDetails> event(EventRef ref) => _api.calendarEvent(ref);

  @override
  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft) => _api.createCalendarEvent(calendar, draft);

  @override
  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope) =>
      _api.updateCalendarEvent(event, draft, scope);

  @override
  Future<void> delete(CalendarEvent event, RecurrenceScope scope) => _api.deleteCalendarEvent(event, scope);

  @override
  Future<CalendarEvent> move(CalendarEvent event, CalendarRef target) => _api.moveCalendarEvent(event, target);

  @override
  Future<void> respond(CalendarEvent event, AttendeeStatus status) => _api.respondToCalendarEvent(event, status);
}
