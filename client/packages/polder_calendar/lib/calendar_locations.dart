import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

class CalendarLocations {
  const CalendarLocations(this.root);

  static const viewParameter = "view";
  static const dateParameter = "date";
  static const eventParameter = "event";
  static const occurrenceParameter = "occurrence";

  final String root;

  String dayAt(CalendarViewMode mode, DateTime date) =>
      Uri(path: root, queryParameters: {viewParameter: mode.slug, dateParameter: _day(date)}).toString();

  String eventAt(EventRef ref, DateTime start) => Uri(
    path: root,
    queryParameters: {
      dateParameter: _day(start),
      eventParameter: "${ref.calendar.calendarId}/${ref.eventId}",
      occurrenceParameter: ?ref.recurrenceId,
    },
  ).toString();

  static String _day(DateTime date) => DateFormat("yyyy-MM-dd").format(date);
}

final calendarLocationsProvider = Provider<CalendarLocations>(
  (ref) => throw UnimplementedError("Each app overrides calendarLocationsProvider"),
);
