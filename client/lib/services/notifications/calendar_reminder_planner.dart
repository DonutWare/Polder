import "package:polder_calendar/polder_calendar.dart";

class PlannedReminder {
  const PlannedReminder({required this.event, required this.at});

  final CalendarEvent event;
  final DateTime at;

  String get key =>
      "${event.ref.calendar.calendarId}|${event.ref.eventId}|${event.ref.recurrenceId ?? ""}|"
      "${at.toUtc().millisecondsSinceEpoch}";
}

abstract final class CalendarReminderPlanner {
  static const limit = 50;
  static const window = Duration(days: 30);

  static List<PlannedReminder> plan(Iterable<CalendarEvent> events, {required DateTime now}) {
    final horizon = now.add(window);
    final planned = <String, PlannedReminder>{};
    for (final event in events) {
      if (event.status == EventStatus.cancelled) continue;
      for (final reminder in event.reminders) {
        final at = triggerOf(event, reminder);
        if (at == null || !at.isAfter(now) || at.isAfter(horizon)) continue;
        final candidate = PlannedReminder(event: event, at: at);
        planned[candidate.key] = candidate;
      }
    }
    return (planned.values.toList()..sort((a, b) => a.at.compareTo(b.at))).take(limit).toList();
  }

  static DateTime? triggerOf(CalendarEvent event, EventReminder reminder) {
    if (reminder.action == ReminderAction.email) return null;
    if (reminder.at case final at?) return at;
    final offset = reminder.offsetMinutes;
    if (offset == null) return null;
    return (reminder.relativeToEnd ? event.end : event.start).add(Duration(minutes: offset));
  }
}
