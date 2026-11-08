import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:intl/intl.dart";
import "package:polder_calendar/polder_calendar.dart";

void main() {
  setUpAll(() => initializeDateFormatting("nl"));

  test("standalone dutch labels capitalize only the first letter", () {
    final day = DateTime(2026, 11, 8);
    expect(DateFormat.yMMMM("nl").formatStandalone(day), "November 2026");
    expect(DateFormat.yMMMMEEEEd("nl").formatStandalone(day), "Zondag 8 november 2026");
  });

  test("labels starting with a digit stay unchanged", () {
    expect(DateFormat.yMMMMd("nl").formatStandalone(DateTime(2026, 11, 8)), "8 november 2026");
  });
}
