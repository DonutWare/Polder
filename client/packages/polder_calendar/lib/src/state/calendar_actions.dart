import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_info.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/model/event_draft.dart";
import "package:polder_calendar/src/source/calendar_source.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/date_math.dart";

final calendarActionsProvider = Provider<CalendarActions>(CalendarActions.new);

final calendarMotionProvider = NotifierProvider<CalendarMotion, EventMotion>(CalendarMotion.new);

class EventMark {
  EventMark(CalendarEvent event, this.scope)
    : series = event.ref.series,
      recurrenceId = event.ref.recurrenceId,
      from = event.start;

  final EventRef series;
  final String? recurrenceId;
  final DateTime from;
  final RecurrenceScope scope;

  bool matches(CalendarEvent event) =>
      event.ref.series == series &&
      switch (scope) {
        RecurrenceScope.thisEvent => event.ref.recurrenceId == recurrenceId,
        RecurrenceScope.following => !event.start.isBefore(from),
        RecurrenceScope.all => true,
      };
}

class EventMotion {
  const EventMotion({this.appearing, this.removing = const []});

  final EventMark? appearing;
  final List<EventMark> removing;

  bool isAppearing(CalendarEvent event) => appearing?.matches(event) ?? false;

  bool isRemoving(CalendarEvent event) => removing.any((mark) => mark.matches(event));
}

class CalendarMotion extends Notifier<EventMotion> {
  static const removeDuration = Duration(milliseconds: 260);

  @override
  EventMotion build() => const EventMotion();

  void appear(CalendarEvent event, RecurrenceScope scope) =>
      state = EventMotion(appearing: EventMark(event, scope), removing: state.removing);

  EventMark remove(CalendarEvent event, RecurrenceScope scope) {
    final mark = EventMark(event, scope);
    state = EventMotion(appearing: state.appearing, removing: [...state.removing, mark]);
    return mark;
  }

  void restore(EventMark mark) => state = EventMotion(
    appearing: state.appearing,
    removing: [
      for (final removing in state.removing)
        if (removing != mark) removing,
    ],
  );
}

class CalendarActions {
  CalendarActions(this._ref);

  final Ref _ref;

  CalendarSource _source(String sourceId) =>
      _ref.read(calendarSourceProvider(sourceId)) ?? (throw StateError("Unknown calendar source $sourceId"));

  CalendarCapabilities capabilitiesOf(CalendarRef calendar) =>
      _ref.read(calendarSourceProvider(calendar.sourceId))?.capabilities ?? CalendarCapabilities.readOnly;

  bool canEdit(CalendarEvent event, CalendarInfo? calendar) =>
      !event.busyOnly && (calendar?.writable ?? false) && capabilitiesOf(event.calendar).canEdit;

  List<CalendarInfo> writableCalendars(List<CalendarInfo> calendars) => [
    for (final calendar in calendars)
      if (calendar.writable && capabilitiesOf(calendar.ref).canCreate) calendar,
  ];

  CalendarMotion get _motion => _ref.read(calendarMotionProvider.notifier);

  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft) => _refreshing(() async {
    final created = await _source(calendar.sourceId).create(calendar, draft);
    _motion.appear(created, RecurrenceScope.all);
    return created;
  }());

  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope, {CalendarRef? moveTo}) =>
      _refreshing(() async {
        final source = _source(event.calendar.sourceId);
        final change = scope == RecurrenceScope.all && event.ref.recurrenceId != null
            ? _shiftToSeries(draft, event, (await source.event(event.ref)).series)
            : draft;
        var updated = await source.update(event, change, scope);
        if (moveTo != null && moveTo != updated.calendar) updated = await source.move(updated, moveTo);
        if (scope == RecurrenceScope.thisEvent) {
          _motion.appear(event, scope);
        } else {
          _motion.appear(updated, RecurrenceScope.all);
        }
        return updated;
      }());

  Future<void> delete(CalendarEvent event, RecurrenceScope scope) async {
    final source = _source(event.calendar.sourceId);
    final mark = _motion.remove(event, scope);
    await Future<void>.delayed(CalendarMotion.removeDuration);
    try {
      await _refreshing(source.delete(event, scope));
    } on Object {
      _motion.restore(mark);
      rethrow;
    }
  }

  Future<void> respond(CalendarEvent event, AttendeeStatus status) =>
      _refreshing(_source(event.calendar.sourceId).respond(event, status));

  EventDraft _shiftToSeries(EventDraft draft, CalendarEvent occurrence, CalendarEvent series) {
    if (draft.allDay) {
      final days = daysBetween(occurrence.start, series.start);
      return draft.copyWith(start: draft.start.addDays(days), end: draft.end.addDays(days));
    }
    final offset = series.start.difference(occurrence.start);
    return draft.copyWith(start: draft.start.add(offset), end: draft.end.add(offset));
  }

  Future<T> _refreshing<T>(Future<T> action) async {
    try {
      return await action;
    } finally {
      _ref.invalidate(monthEventsProvider);
    }
  }
}

DateTime suggestedStart(DateTime day, Iterable<CalendarEvent> events, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final date = day.dateOnly;
  final nextDay = date.nextDay;
  final ends = [
    for (final event in events)
      if (!event.allDay && event.start.isBefore(nextDay) && event.end.isAfter(date) && event.end.isBefore(nextDay))
        event.end,
  ];
  var start = ends.isEmpty
      ? (date.isSameDay(clock)
            ? DateTime(date.year, date.month, date.day, clock.hour + 1)
            : date.add(const Duration(hours: 9)))
      : ends.reduce((latest, end) => end.isAfter(latest) ? end : latest);
  if (date.isSameDay(clock) && start.isBefore(clock)) {
    final minutes = (clock.minute ~/ 30 + 1) * 30;
    start = DateTime(date.year, date.month, date.day, clock.hour, minutes);
  }
  final latest = DateTime(date.year, date.month, date.day, 23);
  return start.isAfter(latest) || !start.isBefore(nextDay) ? latest : start;
}
