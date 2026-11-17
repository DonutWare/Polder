import "package:flutter/widgets.dart";

import "package:polder_calendar/polder_calendar.dart";

class CalendarInsertRequest {
  const CalendarInsertRequest({
    this.title,
    this.description,
    this.location,
    this.rrule,
    this.start,
    this.end,
    this.allDay = false,
    this.attendees = const [],
  });

  static CalendarInsertRequest? fromMap(Object? arguments) {
    if (arguments is! Map) return null;
    final allDay = arguments["allDay"] == true;
    DateTime? time(String key) => switch (arguments[key]) {
      final int millis => _dateTime(millis, allDay: allDay),
      _ => null,
    };
    final start = time("begin");
    final end = time("end");
    return CalendarInsertRequest(
      title: _text(arguments["title"]),
      description: _text(arguments["description"]),
      location: _text(arguments["location"]),
      rrule: _text(arguments["rrule"]),
      start: start,
      end: start != null && end != null && end.isAfter(start) ? end : null,
      allDay: allDay,
      attendees: [
        for (final email in arguments["emails"] as List? ?? const [])
          if (email is String && email.contains("@")) EventPerson(email: email),
      ],
    );
  }

  final String? title;
  final String? description;
  final String? location;
  final String? rrule;
  final DateTime? start;
  final DateTime? end;
  final bool allDay;
  final List<EventPerson> attendees;

  Future<void> open(BuildContext context) =>
      createCalendarEvent(context, start: start, day: start?.dateOnly, allDay: allDay, prefill: applyTo);

  EventDraft applyTo(EventDraft suggested) => suggested.copyWith(
    summary: title ?? suggested.summary,
    description: description ?? suggested.description,
    location: location ?? suggested.location,
    rrule: rrule ?? suggested.rrule,
    end: end ?? suggested.end,
    attendees: attendees.isEmpty ? suggested.attendees : attendees,
  );

  static String? _text(Object? value) => value is String && value.trim().isNotEmpty ? value.trim() : null;

  static DateTime _dateTime(int millis, {required bool allDay}) {
    if (!allDay) return DateTime.fromMillisecondsSinceEpoch(millis);
    final utc = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    return DateTime(utc.year, utc.month, utc.day);
  }
}
