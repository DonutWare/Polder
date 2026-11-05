import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";

void main() {
  const monday = 1;
  const sunday = 0;

  test("week starts on the locale's first day", () {
    final wednesday = DateTime(2026, 11, 4, 15, 30);
    expect(
      visibleRange(CalendarViewMode.week, wednesday, firstDayOfWeek: monday),
      VisibleRange(DateTime(2026, 11, 2), DateTime(2026, 11, 9)),
    );
    expect(
      visibleRange(CalendarViewMode.week, wednesday, firstDayOfWeek: sunday),
      VisibleRange(DateTime(2026, 11, 1), DateTime(2026, 11, 8)),
    );
  });

  test("week containing a DST change still spans seven calendar days", () {
    final range = visibleRange(CalendarViewMode.week, DateTime(2026, 10, 25), firstDayOfWeek: monday);
    expect(range.dayCount, 7);
    expect(range.days.map((day) => day.day), [19, 20, 21, 22, 23, 24, 25]);
  });

  test("three days start at the anchor", () {
    expect(
      visibleRange(CalendarViewMode.threeDays, DateTime(2026, 12, 30), firstDayOfWeek: monday),
      VisibleRange(DateTime(2026, 12, 30), DateTime(2027, 1, 2)),
    );
  });

  test("month grid covers whole weeks around the month", () {
    final november = visibleRange(CalendarViewMode.month, DateTime(2026, 11, 15), firstDayOfWeek: monday);
    expect(november.start, DateTime(2026, 10, 26));
    expect(november.dayCount, 42);

    final february = visibleRange(CalendarViewMode.month, DateTime(2027, 2, 10), firstDayOfWeek: monday);
    expect(february.start, DateTime(2027, 2, 1));
    expect(february.dayCount, 28);
  });

  test("shifting months clamps to the last day", () {
    expect(shiftAnchor(CalendarViewMode.month, DateTime(2027, 1, 31), 1), DateTime(2027, 2, 28));
    expect(shiftAnchor(CalendarViewMode.week, DateTime(2026, 11, 4), -1), DateTime(2026, 10, 28));
  });
}
