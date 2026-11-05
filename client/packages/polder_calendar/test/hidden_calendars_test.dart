import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";

const _holidays = CalendarRef(sourceId: "server", calendarId: "holidays");

final _sinterklaas = CalendarEvent(
  ref: const EventRef(calendar: _holidays, eventId: "sinterklaas"),
  etag: "1",
  summary: "Sinterklaasavond",
  start: DateTime(2026, 12, 5),
  end: DateTime(2026, 12, 6),
  allDay: true,
);

class _ServerLikeSource implements CalendarSource {
  var hidden = false;

  @override
  String get id => "server";

  @override
  String get label => "Server";

  @override
  CalendarCapabilities get capabilities => CalendarCapabilities.readOnly;

  @override
  Stream<CalendarRef> get changes => const Stream.empty();

  @override
  Future<List<CalendarInfo>> calendars() async => [
    CalendarInfo(ref: _holidays, name: "Holidays", access: CalendarAccess.owner, subscription: true, hidden: hidden),
  ];

  @override
  Future<List<CalendarEvent>> events(DateTimeRange range, {Set<CalendarRef>? calendars}) async =>
      hidden ? const [] : [_sinterklaas];

  @override
  Future<void> setHidden(CalendarRef calendar, bool hidden) async => this.hidden = hidden;

  @override
  Future<CalendarEventDetails> event(EventRef ref) => throw UnimplementedError();

  @override
  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft) => throw UnimplementedError();

  @override
  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope) =>
      throw UnimplementedError();

  @override
  Future<void> delete(CalendarEvent event, RecurrenceScope scope) => throw UnimplementedError();

  @override
  Future<CalendarEvent> move(CalendarEvent event, CalendarRef target) => throw UnimplementedError();

  @override
  Future<void> respond(CalendarEvent event, AttendeeStatus status) => throw UnimplementedError();
}

Future<List<CalendarEvent>> _december(ProviderContainer container, VisibleRange range) async {
  await container.read(monthEventsProvider(range.start).future);
  return container.read(rangeEventsProvider(range)).requireValue;
}

void main() {
  test("showing a calendar again brings back events loaded while it was hidden", () async {
    final source = _ServerLikeSource();
    final container = ProviderContainer(overrides: [calendarSourcesProvider.overrideWithValue([source])]);
    addTearDown(container.dispose);
    final december = VisibleRange(DateTime(2026, 12), DateTime(2027));
    final keepAlive = container.listen(rangeEventsProvider(december), (_, _) {});
    addTearDown(keepAlive.close);
    await container.read(calendarListProvider.future);
    final hidden = container.read(hiddenCalendarsProvider.notifier);

    await hidden.toggle(_holidays);
    container.invalidate(monthEventsProvider);
    expect(await _december(container, december), isEmpty);

    await hidden.toggle(_holidays);
    expect((await _december(container, december)).map((event) => event.summary), ["Sinterklaasavond"]);
  });

  test("hiding a calendar keeps its events until they have faded out", () async {
    final source = _ServerLikeSource();
    final container = ProviderContainer(overrides: [calendarSourcesProvider.overrideWithValue([source])]);
    addTearDown(container.dispose);
    final december = VisibleRange(DateTime(2026, 12), DateTime(2027));
    final keepAlive = container.listen(rangeEventsProvider(december), (_, _) {});
    addTearDown(keepAlive.close);
    await container.read(calendarListProvider.future);
    expect(await _december(container, december), hasLength(1));

    final hiding = container.read(hiddenCalendarsProvider.notifier).toggle(_holidays);
    final leaving = container.read(rangeEventsProvider(december)).requireValue.single;
    expect(container.read(calendarMotionProvider).isRemoving(leaving), isTrue);
    await hiding;

    await Future<void>.delayed(CalendarMotion.removeDuration + const Duration(milliseconds: 40));
    expect(container.read(rangeEventsProvider(december)).requireValue, isEmpty);
  });
}
