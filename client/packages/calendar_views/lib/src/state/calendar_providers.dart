import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:calendar_views/src/model/calendar_event.dart";
import "package:calendar_views/src/model/calendar_info.dart";
import "package:calendar_views/src/model/calendar_ref.dart";
import "package:calendar_views/src/source/calendar_source.dart";
import "package:calendar_views/src/state/calendar_actions.dart";
import "package:calendar_views/src/time/calendar_view_mode.dart";
import "package:calendar_views/src/time/date_math.dart";
import "package:flutter/material.dart" show DateTimeRange, Widget;

final calendarSourcesProvider = Provider<List<CalendarSource>>((ref) => const []);

final calendarReminderNoticeProvider = Provider<Widget?>((ref) => null);

final calendarSourceProvider = Provider.family<CalendarSource?, String>(
  (ref, sourceId) => ref.watch(calendarSourcesProvider).where((source) => source.id == sourceId).firstOrNull,
);

final calendarChangesProvider = StreamProvider<CalendarRef>((ref) {
  final sources = ref.watch(calendarSourcesProvider);
  final controller = StreamController<CalendarRef>();
  final subscriptions = [for (final source in sources) source.changes.listen(controller.add)];
  ref.onDispose(() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await controller.close();
  });
  return controller.stream;
});

final calendarListProvider = StreamProvider.autoDispose<List<CalendarInfo>>((ref) {
  ref.listen(calendarChangesProvider, (_, _) => ref.invalidateSelf());
  final sources = ref.watch(calendarSourcesProvider);
  return _latestOfAll([
    for (final source in sources)
      source is LiveCalendarSource ? source.watchCalendars() : Stream.fromFuture(source.calendars()),
  ]);
});

final hiddenCalendarsProvider = NotifierProvider<HiddenCalendarsNotifier, Set<CalendarRef>>(
  HiddenCalendarsNotifier.new,
);

class HiddenCalendarsNotifier extends Notifier<Set<CalendarRef>> {
  @override
  Set<CalendarRef> build() {
    final calendars = ref.watch(calendarListProvider).value ?? const [];
    return {
      for (final calendar in calendars)
        if (calendar.hidden) calendar.ref,
    };
  }

  Future<void> toggle(CalendarRef calendar) async {
    final hide = !state.contains(calendar);
    final motion = ref.read(calendarMotionProvider.notifier);
    unawaited(hide ? motion.hideCalendar(calendar) : motion.revealCalendar(calendar));
    state = hide ? {...state, calendar} : ({...state}..remove(calendar));
    try {
      await ref.read(calendarSourceProvider(calendar.sourceId))?.setHidden(calendar, hide);
      if (!hide) ref.invalidate(monthEventsProvider);
    } catch (_) {
      state = hide ? ({...state}..remove(calendar)) : {...state, calendar};
      rethrow;
    }
  }
}

final monthEventsProvider = StreamProvider.autoDispose.family<List<CalendarEvent>, DateTime>((ref, month) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);
  ref.listen(calendarChangesProvider, (_, _) => ref.invalidateSelf());

  final sources = ref.watch(calendarSourcesProvider);
  final range = DateTimeRange(start: month, end: month.addMonths(1));
  return _latestOfAll([
    for (final source in sources)
      source is LiveCalendarSource ? source.watchEvents(range) : Stream.fromFuture(source.events(range)),
  ]);
});

Stream<List<T>> _latestOfAll<T>(List<Stream<List<T>>> streams) {
  if (streams.isEmpty) return Stream.value(const []);
  if (streams.length == 1) return streams.single;
  final latest = List<List<T>?>.filled(streams.length, null);
  final controller = StreamController<List<T>>();
  final subscriptions = <StreamSubscription<List<T>>>[];
  var open = streams.length;
  controller
    ..onListen = () {
      for (final (index, stream) in streams.indexed) {
        subscriptions.add(
          stream.listen(
            (value) {
              latest[index] = value;
              if (latest.every((list) => list != null)) controller.add([for (final list in latest) ...?list]);
            },
            onError: controller.addError,
            onDone: () {
              if (--open == 0) unawaited(controller.close());
            },
          ),
        );
      }
    }
    ..onCancel = () => Future.wait([for (final subscription in subscriptions) subscription.cancel()]);
  return controller.stream;
}

final rangeEventsProvider = Provider.autoDispose.family<AsyncValue<List<CalendarEvent>>, VisibleRange>((ref, range) {
  final leaving = ref.watch(calendarMotionProvider.select((motion) => motion.hiding));
  final hidden = ref.watch(hiddenCalendarsProvider).difference(leaving);
  final months = <AsyncValue<List<CalendarEvent>>>[
    for (var month = range.start.firstOfMonth; month.isBefore(range.end); month = month.addMonths(1))
      ref.watch(monthEventsProvider(month)),
  ];
  final failure = months.where((month) => month.hasError).firstOrNull;
  if (failure != null) return AsyncError(failure.error!, failure.stackTrace ?? StackTrace.current);
  if (months.any((month) => !month.hasValue)) return const AsyncLoading();

  final seen = <EventRef>{};
  final events = [
    for (final month in months)
      for (final event in month.value!)
        if (!hidden.contains(event.calendar) &&
            event.end.isAfter(range.start) &&
            event.start.isBefore(range.end) &&
            seen.add(event.ref))
          event,
  ]..sort((a, b) => a.start.compareTo(b.start));
  return AsyncData(events);
});

final calendarFocusProvider = NotifierProvider<CalendarFocus, int>(CalendarFocus.new);

class CalendarFocus extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}
