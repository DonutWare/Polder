import "package:flutter/painting.dart";

import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder_calendar/src/model/calendar_event.dart";

part "event_draft.freezed.dart";

enum RecurrenceScope { thisEvent, following, all }

@freezed
abstract class EventDraft with _$EventDraft {
  const factory EventDraft({
    required String summary,
    required DateTime start,
    required DateTime end,
    @Default(false) bool allDay,
    String? description,
    String? location,
    String? url,
    String? timezone,
    String? rrule,
    @Default(EventStatus.confirmed) EventStatus status,
    @Default(EventShowAs.busy) EventShowAs showAs,
    Color? color,
    @Default([]) List<EventPerson> attendees,
    @Default([]) List<EventReminder> reminders,
  }) = _EventDraft;

  factory EventDraft.fromEvent(CalendarEvent event) => EventDraft(
    summary: event.summary,
    start: event.start,
    end: event.end,
    allDay: event.allDay,
    description: event.description,
    location: event.location,
    url: event.url,
    timezone: event.timezone,
    rrule: event.rrule,
    status: event.status,
    showAs: event.showAs,
    color: event.color,
    attendees: [for (final attendee in event.attendees) attendee.person],
    reminders: event.reminders,
  );
}
