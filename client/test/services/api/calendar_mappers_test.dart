import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/calendar.dart" as model;
import "package:polder/models/sharing.dart";
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
      event({"recurring": true, "recurrenceId": "20261105T090000Z", "status": "TENTATIVE"}),
    ).toModel("polder:alice");

    expect(mapped.ref.calendar, const CalendarRef(sourceId: "polder:alice", calendarId: "3"));
    expect(mapped.ref.eventId, "7");
    expect(mapped.ref.recurrenceId, "20261105T090000Z");
    expect(mapped.start, DateTime.utc(2026, 11, 5, 9).toLocal());
    expect(mapped.status, EventStatus.tentative);
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
    ).toWire();

    expect(input.start, DateTime.utc(2026, 11, 5));
    expect(input.end, DateTime.utc(2026, 11, 8));
    expect(input.status, "CONFIRMED");
  });

  test("maps a subscription with its sync state", () {
    final info = wire.Calendar.fromJson({
      "id": 9,
      "uri": "holidays",
      "name": "Holidays",
      "description": "",
      "color": "#46a758",
      "timezone": "",
      "order": 1,
      "kind": "subscription",
      "isDefault": false,
      "access": "owner",
      "owner": {"id": 1, "username": "alice", "displayName": "Alice"},
      "hidden": true,
      "notify": false,
      "sourceUrl": "https://example.com/holidays.ics",
      "fetchedAt": "2026-11-05T08:00:00Z",
      "fetchError": "",
      "createdAt": "2026-11-01T00:00:00Z",
      "updatedAt": "2026-11-05T08:00:00Z",
    }).toInfo("polder:alice");

    expect(info.subscription, isTrue);
    expect(info.shared, isFalse);
    expect(info.hidden, isTrue);
    expect(info.color, const Color(0xFF46A758));
    expect(info.sourceUrl, "https://example.com/holidays.ics");
    expect(info.fetchedAt, DateTime.utc(2026, 11, 5, 8).toLocal());
    expect(info.fetchError, isNull);
  });

  test("maps calendar shares to users and groups", () {
    final toGroup = wire.CalendarShare.fromJson({
      "id": 1,
      "calendarId": 9,
      "access": "freebusy",
      "createdAt": "2026-11-01T00:00:00Z",
      "group": {"id": 4, "name": "Team"},
    }).toModel();
    final toUser = wire.CalendarShare.fromJson({
      "id": 2,
      "calendarId": 9,
      "access": "readwrite",
      "createdAt": "2026-11-01T00:00:00Z",
      "user": {"id": 5, "username": "bob", "displayName": "Bob"},
    }).toModel();

    expect(toGroup.recipient.kind, ShareTargetKind.group);
    expect(toGroup.access, model.CalendarShareAccess.freeBusy);
    expect(toUser.recipient.name, "Bob");
    expect(toUser.access, model.CalendarShareAccess.readWrite);
    expect(model.CalendarShareAccess.read.toWire(), wire.NewCalendarShareAccess.read);
  });

  test("treats a calendar someone else owns as shared", () {
    final info = wire.Calendar.fromJson({
      "id": 10,
      "uri": "team",
      "name": "Team",
      "description": "",
      "color": "#3e63dd",
      "timezone": "",
      "order": 0,
      "kind": "local",
      "isDefault": false,
      "access": "readwrite",
      "owner": {"id": 2, "username": "bob", "displayName": "Bob"},
      "hidden": false,
      "notify": true,
      "createdAt": "2026-11-01T00:00:00Z",
      "updatedAt": "2026-11-01T00:00:00Z",
    }).toInfo("polder:alice");

    expect(info.shared, isTrue);
    expect(info.ownerName, "Bob");
  });
}
