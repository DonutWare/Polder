import "package:flutter/material.dart";

import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_info.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/model/event_draft.dart";

class CalendarCapabilities {
  const CalendarCapabilities({
    this.canCreate = false,
    this.canEdit = false,
    this.recurrenceScopes = false,
    this.rsvp = false,
    this.moveBetweenCalendars = false,
  });

  static const readOnly = CalendarCapabilities();

  final bool canCreate;
  final bool canEdit;
  final bool recurrenceScopes;
  final bool rsvp;
  final bool moveBetweenCalendars;
}

abstract interface class CalendarSource {
  String get id;

  String get label;

  CalendarCapabilities get capabilities;

  Stream<CalendarRef> get changes;

  Future<List<CalendarInfo>> calendars();

  Future<List<CalendarEvent>> events(DateTimeRange range, {Set<CalendarRef>? calendars});

  Future<CalendarEventDetails> event(EventRef ref);

  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft);

  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope);

  Future<void> delete(CalendarEvent event, RecurrenceScope scope);

  Future<CalendarEvent> move(CalendarEvent event, CalendarRef target);

  Future<void> respond(CalendarEvent event, AttendeeStatus status);

  Future<void> setHidden(CalendarRef calendar, bool hidden);
}
