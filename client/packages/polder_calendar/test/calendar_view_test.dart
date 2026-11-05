import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";

class _FakeSource implements CalendarSource {
  _FakeSource(this._events, {this.capabilities = CalendarCapabilities.readOnly, this.series});

  final List<CalendarEvent> _events;
  final CalendarEvent? series;
  final created = <EventDraft>[];
  final updated = <(EventDraft, RecurrenceScope)>[];
  final deleted = <RecurrenceScope>[];

  static const calendar = CalendarRef(sourceId: "fake", calendarId: "1");

  @override
  String get id => "fake";

  @override
  String get label => "Fake";

  @override
  final CalendarCapabilities capabilities;

  @override
  Stream<CalendarRef> get changes => const Stream.empty();

  @override
  Future<List<CalendarInfo>> calendars() async => [
    const CalendarInfo(ref: calendar, name: "Alice", color: Colors.teal, access: CalendarAccess.owner),
  ];

  @override
  Future<List<CalendarEvent>> events(DateTimeRange range, {Set<CalendarRef>? calendars}) async => [
    for (final event in _events)
      if (event.start.isBefore(range.end) && event.end.isAfter(range.start)) event,
  ];

  @override
  Future<CalendarEventDetails> event(EventRef ref) async => CalendarEventDetails(series: series!);

  @override
  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft) async {
    created.add(draft);
    return _event("new", draft.start, draft.end);
  }

  @override
  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope) async {
    updated.add((draft, scope));
    return event;
  }

  @override
  Future<void> delete(CalendarEvent event, RecurrenceScope scope) async => deleted.add(scope);

  @override
  Future<CalendarEvent> move(CalendarEvent event, CalendarRef target) => throw UnimplementedError();

  @override
  Future<void> respond(CalendarEvent event, AttendeeStatus status) => throw UnimplementedError();

  @override
  Future<void> setHidden(CalendarRef calendar, bool hidden) async {}
}

CalendarEvent _event(String id, DateTime start, DateTime end, {bool allDay = false}) => CalendarEvent(
  ref: EventRef(calendar: _FakeSource.calendar, eventId: id),
  etag: id,
  summary: id,
  start: start,
  end: end,
  allDay: allDay,
);

void main() {
  final anchor = DateTime(2026, 11, 4);
  final events = [
    _event("Standup", DateTime(2026, 11, 4, 9), DateTime(2026, 11, 4, 9, 15)),
    _event("Review", DateTime(2026, 11, 4, 9), DateTime(2026, 11, 4, 10)),
    _event("Trip", DateTime(2026, 11, 3), DateTime(2026, 11, 6), allDay: true),
    _event("Late shift", DateTime(2026, 11, 4, 22), DateTime(2026, 11, 5, 2)),
    _event("Dentist", DateTime(2026, 11, 20, 14), DateTime(2026, 11, 20, 15)),
  ];

  Future<void> pump(
    WidgetTester tester,
    CalendarViewMode mode, {
    CalendarNavigate? onNavigate,
    _FakeSource? source,
    bool createOnDayTap = false,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarSourcesProvider.overrideWithValue([source ?? _FakeSource(events)]),
        ],
        child: MaterialApp(
          localizationsDelegates: CalendarLocalizations.localizationsDelegates,
          supportedLocales: CalendarLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => CalendarView(
                mode: mode,
                anchor: anchor,
                onNavigate: onNavigate ?? (_, _) {},
                onEventTap: (event) => openCalendarEvent(context, event),
                onDayTap: createOnDayTap ? (day) => createCalendarEvent(context, day: day) : null,
                onCreate: (start) => createCalendarEvent(context, start: start),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final mode in [CalendarViewMode.day, CalendarViewMode.threeDays, CalendarViewMode.week]) {
    testWidgets("${mode.name} shows timed and all-day events", (tester) async {
      await pump(tester, mode);
      expect(find.text("Trip"), findsWidgets);
      expect(find.textContaining("Standup"), findsOneWidget);
      expect(find.textContaining("Review"), findsOneWidget);
      expect(find.textContaining("Late shift"), findsWidgets);
    });
  }

  testWidgets("month shows events and opens a day", (tester) async {
    DateTime? opened;
    await pump(tester, CalendarViewMode.month, onNavigate: (mode, day) => opened = day);
    expect(find.text("Trip"), findsWidgets);
    expect(find.textContaining("Standup"), findsOneWidget);
    await tester.tap(find.text("18"));
    expect(opened, DateTime(2026, 11, 18));
  });

  testWidgets("schedule lists each day of a multi-day event", (tester) async {
    await pump(tester, CalendarViewMode.schedule);
    expect(find.text("Trip"), findsNWidgets(2));
    expect(find.text("Standup"), findsOneWidget);
    expect(find.text("Wednesday"), findsOneWidget);
    expect(find.textContaining("9:00"), findsWidgets);
  });

  testWidgets("schedule separates weeks with a header", (tester) async {
    await pump(tester, CalendarViewMode.schedule);
    await tester.scrollUntilVisible(find.textContaining("Week 4"), 200, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining("Week 4"), findsWidgets);
  });

  testWidgets("moving to another week from outside slides without navigating again", (tester) async {
    final navigated = <DateTime>[];
    Widget view(DateTime day) => ProviderScope(
      overrides: [
        calendarSourcesProvider.overrideWithValue([_FakeSource(events)]),
      ],
      child: MaterialApp(
        localizationsDelegates: CalendarLocalizations.localizationsDelegates,
        supportedLocales: CalendarLocalizations.supportedLocales,
        home: Scaffold(
          body: CalendarView(mode: CalendarViewMode.week, anchor: day, onNavigate: (_, day) => navigated.add(day)),
        ),
      ),
    );
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(view(anchor));
    await tester.pumpAndSettle();
    await tester.pumpWidget(view(DateTime(2026, 11, 18)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(navigated, isEmpty);
    expect(find.textContaining("Dentist"), findsOneWidget);
  });

  testWidgets("swiping a week reports the next anchor", (tester) async {
    final navigated = Completer<DateTime>();
    await pump(tester, CalendarViewMode.week, onNavigate: (_, day) => navigated.complete(day));
    await tester.fling(find.byType(PageView), const Offset(-800, 0), 2000);
    await tester.pumpAndSettle();
    expect(await navigated.future, DateTime(2026, 11, 11));
  });

  group("editing", () {
    const editable = CalendarCapabilities(canCreate: true, canEdit: true, recurrenceScopes: true);
    final series = _event(
      "Sync",
      DateTime(2026, 10, 7, 10),
      DateTime(2026, 10, 7, 10, 30),
    ).copyWith(recurring: true, rrule: "FREQ=WEEKLY;BYDAY=WE");
    final occurrence = series.copyWith(
      ref: const EventRef(calendar: _FakeSource.calendar, eventId: "Sync", recurrenceId: "20261104T090000Z"),
      start: DateTime(2026, 11, 4, 10),
      end: DateTime(2026, 11, 4, 10, 30),
    );
    _FakeSource source() => _FakeSource([occurrence], capabilities: editable, series: series);

    Future<void> editOccurrence(WidgetTester tester, _FakeSource fake, String scope) async {
      await pump(tester, CalendarViewMode.week, source: fake);
      await tester.tap(find.textContaining("Sync"));
      await tester.pumpAndSettle();
      expect(find.text("Every week on Wednesday"), findsOneWidget);
      await tester.tap(find.byTooltip("Edit"));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, "Sync"), "Sync moved");
      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();
      await tester.tap(find.text(scope));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
    }

    testWidgets("changes a single occurrence", (tester) async {
      final fake = source();
      await editOccurrence(tester, fake, "This event");
      final (draft, scope) = fake.updated.single;
      expect(scope, RecurrenceScope.thisEvent);
      expect(draft.summary, "Sync moved");
      expect(draft.start, DateTime(2026, 11, 4, 10));
      expect(draft.rrule, series.rrule);
    });

    testWidgets("changes the whole series from its first start", (tester) async {
      final fake = source();
      await editOccurrence(tester, fake, "All events");
      final (draft, scope) = fake.updated.single;
      expect(scope, RecurrenceScope.all);
      expect(draft.start, DateTime(2026, 10, 7, 10));
      expect(draft.end, DateTime(2026, 10, 7, 10, 30));
    });

    testWidgets("removes the whole series at once", (tester) async {
      final fake = source();
      await pump(tester, CalendarViewMode.week, source: fake);
      await tester.tap(find.textContaining("Sync"));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip("Delete"));
      await tester.pumpAndSettle();
      expect(find.text("Delete recurring event"), findsOneWidget);
      await tester.tap(find.text("All events"));
      await tester.tap(find.widgetWithText(FilledButton, "Delete"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final fading = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.textContaining("Sync"), matching: find.byType(AnimatedOpacity)).first,
      );
      expect(fading.opacity, 0);
      expect(fake.deleted, isEmpty);
      await tester.pump(CalendarMotion.removeDuration);
      await tester.pumpAndSettle();
      expect(fake.deleted, [RecurrenceScope.all]);
    });

    testWidgets("tapping an empty slot creates an event there", (tester) async {
      final fake = source();
      await pump(tester, CalendarViewMode.day, source: fake);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 2000));
      await tester.pumpAndSettle();
      final grid = tester.getTopLeft(find.byType(SingleChildScrollView));
      await tester.tapAt(grid + const Offset(400, 48 * 14 + 10));
      await tester.pumpAndSettle();
      expect(find.text("New event"), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, "Add title"), "Lunch");
      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();
      final draft = fake.created.single;
      expect(draft.summary, "Lunch");
      expect(draft.start, DateTime(2026, 11, 4, 14));
      expect(draft.end, DateTime(2026, 11, 4, 15));
    });
  });

  group("suggested start", () {
    final now = DateTime(2026, 11, 4, 8, 10);
    final day = DateTime(2026, 11, 6);

    test("follows the last event of the day", () {
      final busy = [
        _event("a", DateTime(2026, 11, 6, 9), DateTime(2026, 11, 6, 10, 30)),
        _event("b", DateTime(2026, 11, 6, 13), DateTime(2026, 11, 6, 14, 15)),
        _event("trip", DateTime(2026, 11, 5), DateTime(2026, 11, 8), allDay: true),
      ];
      expect(suggestedStart(day, busy, now: now), DateTime(2026, 11, 6, 14, 15));
    });

    test("starts at nine on an empty day and the next hour today", () {
      expect(suggestedStart(day, const [], now: now), DateTime(2026, 11, 6, 9));
      expect(suggestedStart(now, const [], now: now), DateTime(2026, 11, 4, 9));
    });

    test("never suggests a time that already passed today", () {
      final earlier = [_event("a", DateTime(2026, 11, 4, 7), DateTime(2026, 11, 4, 7, 30))];
      expect(suggestedStart(now, earlier, now: now), DateTime(2026, 11, 4, 8, 30));
    });
  });

  testWidgets("tapping a month day creates an event after that day's last one", (tester) async {
    final fake = _FakeSource(events, capabilities: const CalendarCapabilities(canCreate: true, canEdit: true));
    await pump(tester, CalendarViewMode.month, source: fake, createOnDayTap: true);
    await tester.tap(find.text("20"));
    await tester.pumpAndSettle();
    expect(find.text("New event"), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, "Add title"), "Follow-up");
    await tester.tap(find.text("Save"));
    await tester.pumpAndSettle();
    expect(fake.created.single.start, DateTime(2026, 11, 20, 15));
    expect(fake.created.single.end, DateTime(2026, 11, 20, 16));
  });

  testWidgets("today scrolls the schedule back even when the date stays the same", (tester) async {
    final today = DateTime.now().dateOnly;
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarSourcesProvider.overrideWithValue([_FakeSource(events)]),
        ],
        child: MaterialApp(
          localizationsDelegates: CalendarLocalizations.localizationsDelegates,
          supportedLocales: CalendarLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
              actions: [CalendarPeriodButtons(mode: CalendarViewMode.schedule, anchor: today, onNavigate: (_, _) {})],
            ),
            body: CalendarView(mode: CalendarViewMode.schedule, anchor: today, onNavigate: (_, _) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, greaterThan(500));
    await tester.tap(find.byTooltip("Today"));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
  });
}
