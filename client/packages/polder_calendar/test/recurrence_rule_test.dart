import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";

void main() {
  final wednesday = DateTime(2026, 11, 4, 10);

  test("parses and encodes supported rules", () {
    final rule = RecurrenceRule.tryParse("RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE;UNTIL=20261231T230000Z")!;
    expect(rule.frequency, RecurrenceFrequency.weekly);
    expect(rule.interval, 2);
    expect(rule.weekdays, {DateTime.monday, DateTime.wednesday});
    expect(rule.encode(), "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE;UNTIL=20261231T230000Z");
  });

  test("rejects rules the editor cannot represent", () {
    expect(RecurrenceRule.tryParse("FREQ=WEEKLY;BYDAY=1MO"), isNull);
    expect(RecurrenceRule.tryParse("FREQ=MONTHLY;BYDAY=1MO,2TU"), isNull);
    expect(RecurrenceRule.tryParse("FREQ=MONTHLY;BYDAY=0MO"), isNull);
    expect(RecurrenceRule.tryParse("FREQ=HOURLY"), isNull);
    expect(RecurrenceRule.tryParse("FREQ=DAILY;BYHOUR=9"), isNull);
    expect(RecurrenceRule.tryParse(""), isNull);
  });

  test("round-trips monthly rules on an ordinal weekday", () {
    final first = RecurrenceRule.tryParse("FREQ=MONTHLY;INTERVAL=2;BYDAY=1WE;COUNT=13")!;
    expect(first.weekdays, {DateTime.wednesday});
    expect(first.weekdayPosition, 1);
    expect(first.encode(), "FREQ=MONTHLY;INTERVAL=2;BYDAY=1WE;COUNT=13");
    const last = RecurrenceRule(RecurrenceFrequency.monthly, weekdays: {DateTime.friday}, weekdayPosition: -1);
    expect(last.encode(), "FREQ=MONTHLY;BYDAY=-1FR");
    expect(RecurrenceRule.tryParse("FREQ=MONTHLY;BYDAY=+2TU")!.weekdayPosition, 2);
  });

  test("ordinal weekday rules never match presets", () {
    expect(RepeatOption.matching(RecurrenceRule.tryParse("FREQ=MONTHLY;BYDAY=1WE")!, wednesday), isNull);
  });

  test("matches presets against the start date", () {
    RepeatOption? match(String rule) => RepeatOption.matching(RecurrenceRule.tryParse(rule)!, wednesday);
    expect(match("FREQ=WEEKLY"), RepeatOption.weekly);
    expect(match("FREQ=WEEKLY;BYDAY=WE"), RepeatOption.weekly);
    expect(match("FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"), RepeatOption.weekdays);
    expect(match("FREQ=MONTHLY;BYMONTHDAY=4"), RepeatOption.monthly);
    expect(match("FREQ=DAILY;COUNT=5"), isNull);
    expect(RepeatOption.weekly.ruleFor(wednesday).encode(), "FREQ=WEEKLY;BYDAY=WE");
  });
}
