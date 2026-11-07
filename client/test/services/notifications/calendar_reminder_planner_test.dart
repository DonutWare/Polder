import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notifications/calendar_reminder_planner.dart";
import "package:polder_calendar/polder_calendar.dart";

CalendarEvent event({
  required DateTime start,
  Duration length = const Duration(hours: 1),
  List<EventReminder> reminders = const [],
  String id = "1",
  String? recurrenceId,
  bool allDay = false,
  EventStatus status = EventStatus.confirmed,
}) => CalendarEvent(
  ref: EventRef(
    calendar: const CalendarRef(sourceId: "polder:alice", calendarId: "3"),
    eventId: id,
    recurrenceId: recurrenceId,
  ),
  etag: "e",
  summary: "Standup",
  start: start,
  end: start.add(length),
  allDay: allDay,
  status: status,
  reminders: reminders,
);

void main() {
  final now = DateTime(2026, 11, 6, 9);

  test("reminders trigger relative to the start, the end, or at a fixed moment", () {
    final start = DateTime(2026, 11, 6, 10);
    final at = DateTime(2026, 11, 6, 9, 30);
    final planned = CalendarReminderPlanner.plan([
      event(
        start: start,
        reminders: [
          const EventReminder(offsetMinutes: -10),
          const EventReminder(offsetMinutes: 0),
          const EventReminder(offsetMinutes: -5, relativeToEnd: true),
          EventReminder(at: at),
        ],
      ),
    ], now: now);

    expect(planned.map((reminder) => reminder.at), [
      at,
      DateTime(2026, 11, 6, 9, 50),
      start,
      DateTime(2026, 11, 6, 10, 55),
    ]);
  });

  test("all-day reminders count from midnight", () {
    final planned = CalendarReminderPlanner.plan([
      event(
        start: DateTime(2026, 11, 8),
        length: const Duration(days: 1),
        allDay: true,
        reminders: const [
          EventReminder(offsetMinutes: 9 * 60),
          EventReminder(offsetMinutes: -15 * 60),
        ],
      ),
    ], now: now);

    expect(planned.map((reminder) => reminder.at), [DateTime(2026, 11, 7, 9), DateTime(2026, 11, 8, 9)]);
  });

  test("past, far away, email and cancelled reminders are left out", () {
    final planned = CalendarReminderPlanner.plan([
      event(start: DateTime(2026, 11, 6, 9, 5), reminders: const [EventReminder(offsetMinutes: -10)]),
      event(start: DateTime(2027, 1, 1), reminders: const [EventReminder(offsetMinutes: -10)]),
      event(
        start: DateTime(2026, 11, 7),
        reminders: const [EventReminder(action: ReminderAction.email, offsetMinutes: -10)],
      ),
      event(
        start: DateTime(2026, 11, 7),
        status: EventStatus.cancelled,
        reminders: const [EventReminder(offsetMinutes: -10)],
      ),
    ], now: now);

    expect(planned, isEmpty);
  });

  test("each occurrence of a repeating event gets its own reminder, nearest first and capped", () {
    final occurrences = [
      for (var day = 0; day < 60; day++)
        event(
          start: DateTime(2026, 11, 7 + day % 29, 10),
          recurrenceId: "occurrence-$day",
          reminders: const [EventReminder(offsetMinutes: -10)],
        ),
    ];

    final planned = CalendarReminderPlanner.plan(occurrences.reversed, now: now);

    expect(planned, hasLength(CalendarReminderPlanner.limit));
    expect(planned.first.at, DateTime(2026, 11, 7, 9, 50));
    expect(planned.map((reminder) => reminder.key).toSet(), hasLength(CalendarReminderPlanner.limit));
    for (var i = 1; i < planned.length; i++) {
      expect(planned[i].at.isBefore(planned[i - 1].at), isFalse);
    }
  });

  test("the same reminder twice is planned once", () {
    final twice = event(
      start: DateTime(2026, 11, 6, 10),
      reminders: const [EventReminder(offsetMinutes: -10), EventReminder(offsetMinutes: -10)],
    );

    expect(CalendarReminderPlanner.plan([twice, twice], now: now), hasLength(1));
  });
}
