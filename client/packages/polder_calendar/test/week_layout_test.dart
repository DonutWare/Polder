import "package:flutter_test/flutter_test.dart";
import "package:polder_calendar/polder_calendar.dart";

void main() {
  test("regions pick their customary first day of the week", () {
    expect(WeekLayout.forRegion("NL").firstDay, DateTime.monday);
    expect(WeekLayout.forRegion("us").firstDay, 0);
    expect(WeekLayout.forRegion("EG").firstDay, DateTime.saturday);
    expect(WeekLayout.forRegion(null).firstDay, DateTime.monday);
  });

  test("weekends follow the region", () {
    final saturday = DateTime(2026, 11, 14);
    final friday = DateTime(2026, 11, 13);
    expect(WeekLayout.forRegion("NL").isWeekend(saturday), isTrue);
    expect(WeekLayout.forRegion("NL").isWeekend(friday), isFalse);
    expect(WeekLayout.forRegion("AE").isWeekend(friday), isTrue);
  });

  test("a chosen first day overrides the region but keeps its weekend", () {
    final layout = WeekLayout.forRegion("AE").startingOn(0);
    expect(layout.firstDay, 0);
    expect(layout.weekend, {DateTime.friday, DateTime.saturday});
    expect(WeekLayout.forRegion("US").startingOn(null), WeekLayout.forRegion("US"));
  });
}
