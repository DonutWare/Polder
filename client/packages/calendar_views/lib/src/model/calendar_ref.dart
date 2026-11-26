import "package:freezed_annotation/freezed_annotation.dart";

part "calendar_ref.freezed.dart";

@freezed
abstract class CalendarRef with _$CalendarRef {
  const factory CalendarRef({required String sourceId, required String calendarId}) = _CalendarRef;
}

@freezed
abstract class EventRef with _$EventRef {
  const EventRef._();

  const factory EventRef({required CalendarRef calendar, required String eventId, String? recurrenceId}) = _EventRef;

  EventRef get series => EventRef(calendar: calendar, eventId: eventId);
}
