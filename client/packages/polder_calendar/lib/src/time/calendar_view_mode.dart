import "package:polder_calendar/src/time/date_math.dart";

enum CalendarViewMode {
  schedule("schedule"),
  day("day"),
  threeDays("3day"),
  week("week"),
  month("month");

  const CalendarViewMode(this.slug);

  final String slug;

  static CalendarViewMode fromSlug(String? slug) =>
      values.where((mode) => mode.slug == slug).firstOrNull ?? CalendarViewMode.week;

  bool get isTimeGrid => this == day || this == threeDays || this == week;

  int get dayCount => switch (this) {
    day => 1,
    threeDays => 3,
    week => 7,
    schedule || month => 0,
  };
}

class VisibleRange {
  const VisibleRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get dayCount => daysBetween(start, end);

  Iterable<DateTime> get days => daysIn(start, end);

  bool contains(DateTime day) => !day.dateOnly.isBefore(start) && day.dateOnly.isBefore(end);

  @override
  bool operator ==(Object other) => other is VisibleRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => "VisibleRange($start, $end)";
}

VisibleRange visibleRange(CalendarViewMode mode, DateTime anchor, {required int firstDayOfWeek}) {
  final day = anchor.dateOnly;
  switch (mode) {
    case CalendarViewMode.day:
      return VisibleRange(day, day.nextDay);
    case CalendarViewMode.threeDays:
      return VisibleRange(day, day.addDays(3));
    case CalendarViewMode.week:
      final start = day.startOfWeek(firstDayOfWeek);
      return VisibleRange(start, start.addDays(7));
    case CalendarViewMode.month:
      final start = day.firstOfMonth.startOfWeek(firstDayOfWeek);
      final monthEnd = DateTime(day.year, day.month + 1);
      final weeks = (daysBetween(start, monthEnd) / 7).ceil();
      return VisibleRange(start, start.addDays(weeks * 7));
    case CalendarViewMode.schedule:
      return VisibleRange(day, day.addMonths(1));
  }
}

DateTime shiftAnchor(CalendarViewMode mode, DateTime anchor, int steps) => switch (mode) {
  CalendarViewMode.day => anchor.dateOnly.addDays(steps),
  CalendarViewMode.threeDays => anchor.dateOnly.addDays(3 * steps),
  CalendarViewMode.week => anchor.dateOnly.addDays(7 * steps),
  CalendarViewMode.month || CalendarViewMode.schedule => anchor.dateOnly.addMonths(steps),
};
