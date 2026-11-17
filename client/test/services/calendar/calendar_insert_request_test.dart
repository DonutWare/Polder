import "package:flutter_test/flutter_test.dart";

import "package:polder/services/calendar/calendar_insert_request.dart";
import "package:polder_calendar/polder_calendar.dart";

void main() {
  final suggested = EventDraft(summary: "", start: DateTime(2026, 11, 20, 9), end: DateTime(2026, 11, 20, 10));

  test("ignores anything that is not a map", () {
    expect(CalendarInsertRequest.fromMap(null), isNull);
    expect(CalendarInsertRequest.fromMap("insert"), isNull);
  });

  test("reads timed events in local time", () {
    final begin = DateTime(2026, 11, 21, 18, 30);
    final end = DateTime(2026, 11, 21, 21);
    final request = CalendarInsertRequest.fromMap({
      "title": " Dinner ",
      "location": "Amsterdam",
      "begin": begin.millisecondsSinceEpoch,
      "end": end.millisecondsSinceEpoch,
      "allDay": false,
      "emails": ["alice@example.com", "", "not-an-email"],
    })!;

    expect(request.title, "Dinner");
    expect(request.start, begin);
    expect(request.end, end);
    expect(request.attendees, [const EventPerson(email: "alice@example.com")]);
  });

  test("reads all-day events as UTC dates", () {
    final request = CalendarInsertRequest.fromMap({
      "begin": DateTime.utc(2026, 12, 24).millisecondsSinceEpoch,
      "end": DateTime.utc(2026, 12, 26).millisecondsSinceEpoch,
      "allDay": true,
    })!;

    expect(request.start, DateTime(2026, 12, 24));
    expect(request.end, DateTime(2026, 12, 26));
    expect(request.allDay, isTrue);
  });

  test("drops an end that is not after the start", () {
    final begin = DateTime(2026, 11, 21, 18).millisecondsSinceEpoch;
    final request = CalendarInsertRequest.fromMap({"begin": begin, "end": begin})!;

    expect(request.end, isNull);
  });

  test("keeps the suggested values for missing fields", () {
    final draft = CalendarInsertRequest.fromMap({"title": "Party", "description": "  "})!.applyTo(suggested);

    expect(draft.summary, "Party");
    expect(draft.description, isNull);
    expect(draft.start, suggested.start);
    expect(draft.end, suggested.end);
  });

  test("overrides the suggested values with the request", () {
    final end = DateTime(2026, 11, 20, 12);
    final draft = CalendarInsertRequest(
      title: "Meeting",
      location: "Office",
      rrule: "FREQ=WEEKLY",
      end: end,
      attendees: const [EventPerson(email: "bob@example.com")],
    ).applyTo(suggested);

    expect(draft.summary, "Meeting");
    expect(draft.location, "Office");
    expect(draft.rrule, "FREQ=WEEKLY");
    expect(draft.end, end);
    expect(draft.attendees.single.email, "bob@example.com");
  });
}
