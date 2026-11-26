extension CalendarDate on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  DateTime addDays(int days) => DateTime(year, month, day + days, hour, minute, second, millisecond);

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  int get minuteOfDay => hour * 60 + minute;

  DateTime startOfWeek(int firstDayOfWeek) {
    final offset = (weekday % 7 - firstDayOfWeek) % 7;
    return DateTime(year, month, day - offset);
  }

  DateTime get firstOfMonth => DateTime(year, month);

  DateTime addMonths(int months) {
    final target = DateTime(year, month + months);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(target.year, target.month, day > lastDay ? lastDay : day);
  }
}

int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

Iterable<DateTime> daysIn(DateTime start, DateTime end) sync* {
  for (var day = start.dateOnly; day.isBefore(end); day = day.nextDay) {
    yield day;
  }
}

int weekNumber(DateTime day, int firstDayOfWeek) {
  final weekStart = day.startOfWeek(firstDayOfWeek);
  if (firstDayOfWeek == DateTime.monday) {
    final thursday = weekStart.addDays(3);
    return daysBetween(DateTime(thursday.year), thursday) ~/ 7 + 1;
  }
  final weekEnd = weekStart.addDays(6);
  return daysBetween(DateTime(weekEnd.year).startOfWeek(firstDayOfWeek), weekStart) ~/ 7 + 1;
}
