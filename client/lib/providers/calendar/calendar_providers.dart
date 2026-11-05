import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/calendar.dart";
import "package:polder/models/calendar_reminder.dart";
import "package:polder/models/server_event.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/util/guarded_refresh.dart";
import "package:polder_calendar/polder_calendar.dart" as cal;

final calendarsProvider = FutureProvider.autoDispose<List<CalendarSummary>>(
  (ref) => ref.watch(polderApiProvider).calendars(),
);

final calendarFeedsProvider = AsyncNotifierProvider.autoDispose.family<CalendarFeedsNotifier, List<CalendarFeed>, int>(
  CalendarFeedsNotifier.new,
);

class CalendarFeedsNotifier extends AsyncNotifier<List<CalendarFeed>> with GuardedRefresh {
  CalendarFeedsNotifier(this.calendarId);

  final int calendarId;

  @override
  Future<List<CalendarFeed>> build() => ref.watch(polderApiProvider).calendarFeeds(calendarId);

  Future<void> refresh() => refreshWith(() => ref.read(polderApiProvider).calendarFeeds(calendarId));

  Future<CreatedCalendarFeed> create({required CalendarFeedMode mode, String? name}) async {
    final created = await ref.read(polderApiProvider).createCalendarFeed(calendarId, mode: mode, name: name);
    state = AsyncData([...?state.value, created.feed]);
    return created;
  }

  Future<void> revoke(CalendarFeed feed) async {
    await ref.read(polderApiProvider).deleteCalendarFeed(calendarId, feed.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != feed.id)]);
  }
}

final polderCalendarSourceProvider = Provider<PolderCalendarSource?>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) return null;
  final sourceId = "polder:$accountId";
  final events = ref.watch(eventsClientProvider)?.events ?? const Stream<ServerEvent>.empty();
  return PolderCalendarSource(
    ref.watch(polderApiProvider),
    id: sourceId,
    label: accountId,
    changes: events
        .where((event) => event is CalendarChangedEvent)
        .map(
          (event) => cal.CalendarRef(sourceId: sourceId, calendarId: "${(event as CalendarChangedEvent).calendarId}"),
        ),
  );
});

final polderCalendarSourcesOverride = cal.calendarSourcesProvider.overrideWith((ref) {
  final source = ref.watch(polderCalendarSourceProvider);
  return [?source];
});

final calendarRemindersProvider = StreamProvider<CalendarReminder>((ref) {
  final events = ref.watch(eventsClientProvider)?.events ?? const Stream<ServerEvent>.empty();
  return events
      .where((event) => event is CalendarReminderEvent)
      .map((event) => (event as CalendarReminderEvent).reminder);
});

final calendarViewModeProvider = NotifierProvider<CalendarViewModeNotifier, cal.CalendarViewMode?>(
  CalendarViewModeNotifier.new,
);

class CalendarViewModeNotifier extends Notifier<cal.CalendarViewMode?> {
  static const _key = "polder.calendar.view";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  var _chosen = false;

  @override
  cal.CalendarViewMode? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final saved = cal.CalendarViewMode.values.asNameMap()[(await _preferences.readJson(_key))?["mode"]];
    if (ref.mounted && !_chosen && saved != null) state = saved;
  }

  Future<void> select(cal.CalendarViewMode mode) async {
    _chosen = true;
    if (state == mode) return;
    state = mode;
    await _preferences.writeJson(_key, {"mode": mode.name});
  }
}
