import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder_calendar/src/model/calendar_ref.dart";

part "calendar_event.freezed.dart";

enum EventStatus { confirmed, tentative, cancelled }

enum EventShowAs { busy, free }

enum AttendeeStatus { needsAction, accepted, declined, tentative, delegated }

enum AttendeeRole { chair, required, optional, nonParticipant }

enum ReminderAction { display, email, audio }

@freezed
abstract class EventPerson with _$EventPerson {
  const EventPerson._();

  const factory EventPerson({required String email, String? name, @Default(false) bool self}) = _EventPerson;

  String get label => (name?.isNotEmpty ?? false) ? name! : email;
}

@freezed
abstract class EventAttendee with _$EventAttendee {
  const factory EventAttendee({
    required EventPerson person,
    @Default(AttendeeStatus.needsAction) AttendeeStatus status,
    @Default(AttendeeRole.required) AttendeeRole role,
  }) = _EventAttendee;
}

@freezed
abstract class EventReminder with _$EventReminder {
  const factory EventReminder({
    @Default(ReminderAction.display) ReminderAction action,
    int? offsetMinutes,
    @Default(false) bool relativeToEnd,
    DateTime? at,
  }) = _EventReminder;
}

@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const CalendarEvent._();

  const factory CalendarEvent({
    required EventRef ref,
    required String etag,
    required String summary,
    required DateTime start,
    required DateTime end,
    @Default(false) bool allDay,
    String? description,
    String? location,
    String? url,
    String? timezone,
    String? rrule,
    @Default(false) bool recurring,
    @Default(false) bool modifiedOccurrence,
    @Default(EventStatus.confirmed) EventStatus status,
    @Default(EventShowAs.busy) EventShowAs showAs,
    @Default(false) bool busyOnly,
    EventPerson? organizer,
    @Default([]) List<EventAttendee> attendees,
    @Default([]) List<EventReminder> reminders,
  }) = _CalendarEvent;

  CalendarRef get calendar => ref.calendar;

  Duration get duration => end.difference(start);

  EventAttendee? get selfAttendee => attendees.where((attendee) => attendee.person.self).firstOrNull;

  bool get isInvitation => selfAttendee != null && !(organizer?.self ?? false);
}

@freezed
abstract class CalendarEventDetails with _$CalendarEventDetails {
  const factory CalendarEventDetails({required CalendarEvent series, @Default([]) List<CalendarEvent> overrides}) =
      _CalendarEventDetails;
}
