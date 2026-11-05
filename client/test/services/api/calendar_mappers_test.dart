import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/services/api/calendar_mappers.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder_calendar/polder_calendar.dart";

void main() {
  Map<String, dynamic> event(Map<String, dynamic> fields) => {
    "id": 7,
    "calendarId": 3,
    "uid": "uid-7",
    "etag": "\"e1\"",
    "summary": "Standup",
    "start": "2026-11-05T09:00:00Z",
    "end": "2026-11-05T09:15:00Z",
    "allDay": false,
    "recurring": false,
    "override": false,
    "sequence": 0,
    "showAs": "busy",
    "status": "CONFIRMED",
    "busyOnly": false,
    "updatedAt": "2026-11-01T00:00:00Z",
    ...fields,
  };

  test("maps a recurring occurrence with its refs", () {
    final mapped = wire.Event.fromJson(
      event({"recurring": true, "recurrenceId": "20261105T090000Z", "color": "#FF0000", "status": "TENTATIVE"}),
    ).toModel("polder:alice");

    expect(mapped.ref.calendar, const CalendarRef(sourceId: "polder:alice", calendarId: "3"));
    expect(mapped.ref.eventId, "7");
    expect(mapped.ref.recurrenceId, "20261105T090000Z");
    expect(mapped.start, DateTime.utc(2026, 11, 5, 9).toLocal());
    expect(mapped.status, EventStatus.tentative);
    expect(mapped.color, const Color(0xFFFF0000));
  });

  test("keeps all-day dates on the calendar day", () {
    final mapped = wire.Event.fromJson(
      event({"allDay": true, "start": "2026-11-05T00:00:00Z", "end": "2026-11-07T00:00:00Z"}),
    ).toModel("polder:alice");

    expect(mapped.start, DateTime(2026, 11, 5));
    expect(mapped.end, DateTime(2026, 11, 7));
  });

  test("maps the self attendee and reminders", () {
    final mapped = wire.Event.fromJson(
      event({
        "organizer": {"email": "bob@example.com", "self": false},
        "attendees": [
          {"email": "alice@example.com", "self": true, "status": "NEEDS-ACTION", "role": "OPT-PARTICIPANT"},
        ],
        "alarms": [
          {"action": "DISPLAY", "offsetMinutes": -10},
        ],
      }),
    ).toModel("polder:alice");

    expect(mapped.isInvitation, isTrue);
    expect(mapped.selfAttendee?.role, AttendeeRole.optional);
    expect(mapped.reminders.single.offsetMinutes, -10);
  });

  test("sends all-day drafts as UTC dates", () {
    final input = EventDraft(
      summary: "Trip",
      start: DateTime(2026, 11, 5),
      end: DateTime(2026, 11, 8),
      allDay: true,
      color: const Color(0xFF00FF00),
    ).toWire();

    expect(input.start, DateTime.utc(2026, 11, 5));
    expect(input.end, DateTime.utc(2026, 11, 8));
    expect(input.color, "#00FF00");
    expect(input.status, "CONFIRMED");
  });
}
