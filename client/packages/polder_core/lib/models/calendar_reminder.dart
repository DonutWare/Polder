import "package:freezed_annotation/freezed_annotation.dart";

part "calendar_reminder.freezed.dart";

@freezed
abstract class CalendarReminder with _$CalendarReminder {
  const factory CalendarReminder({
    required int calendarId,
    required int eventId,
    required String uid,
    String? recurrenceId,
    required String summary,
    String? location,
    required DateTime start,
    required DateTime end,
    required bool allDay,
    required DateTime triggerAt,
  }) = _CalendarReminder;
}
