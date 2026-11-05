import "package:flutter_test/flutter_test.dart";

import "package:polder/services/calendar/calendar_catalog.dart";

void main() {
  test("builds Google holiday feeds in the user's language", () {
    final netherlands = CalendarCatalog.countryFor(region: "nl", language: "nl")!;

    expect(
      CalendarCatalog.holidays(netherlands, "nl"),
      "https://calendar.google.com/calendar/ical/nl.dutch%23holiday%40group.v.calendar.google.com/public/basic.ics",
    );
    expect(CalendarCatalog.religion(CatalogReligion.jewish, "en"), contains("en.judaism%23holiday"));
  });

  test("recognises a feed the server stored in its own escaping", () {
    final offered = CalendarCatalog.weekNumbers("en");
    const stored = "https://calendar.google.com/calendar/ical/e_2_en%23weeknum@group.v.calendar.google.com/public/basic.ics";

    expect(CalendarCatalog.normalized(stored), CalendarCatalog.normalized(offered));
    expect(CalendarCatalog.normalized("webcal://example.com/a.ics"), "https://example.com/a.ics");
  });

  test("falls back from the region to the language", () {
    expect(CalendarCatalog.countryFor(region: "BE", language: "nl")?.googleId, "be");
    expect(CalendarCatalog.countryFor(region: null, language: "nl")?.googleId, "dutch");
    expect(CalendarCatalog.countryFor(region: null, language: "en"), isNull);
  });

  test("lists every country once", () {
    final regions = CalendarCatalog.countries.map((country) => country.region).toList();
    expect(regions.toSet().length, regions.length);
  });

  test("uses the app language when Google offers it, English otherwise", () {
    expect(CalendarCatalog.languageFor("nl"), "nl");
    expect(CalendarCatalog.languageFor("zh"), "zh-CN");
    expect(CalendarCatalog.languageFor("xx"), "en");
  });
}
