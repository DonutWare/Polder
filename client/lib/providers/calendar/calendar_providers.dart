import "dart:typed_data";
import "dart:ui";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/calendar.dart";
import "package:polder/models/server_event.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/util/guarded_refresh.dart";
import "package:polder/widgets/notifications/notification_notices.dart";
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
  final sourceId = PolderCalendarSource.idFor(accountId);
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

final calendarReminderNoticeOverride = cal.calendarReminderNoticeProvider.overrideWithValue(
  const CalendarReminderNotice(),
);

final calendarAgendasProvider = Provider<CalendarAgendas>(CalendarAgendas.new);

class CalendarAgendas {
  CalendarAgendas(this._ref);

  final Ref _ref;

  PolderApi get _api => _ref.read(polderApiProvider);

  String get _sourceId => _ref.read(polderCalendarSourceProvider)!.id;

  int _id(cal.CalendarInfo calendar) => int.parse(calendar.ref.calendarId);

  Future<T> _changing<T>(Future<T> Function() change) async {
    final result = await change();
    _ref.invalidate(cal.calendarListProvider);
    _ref.invalidate(calendarsProvider);
    return result;
  }

  Future<cal.CalendarInfo> create({required String name, required Color color}) =>
      _changing(() => _api.createCalendar(_sourceId, name: name, color: color));

  Future<void> edit(cal.CalendarInfo calendar, {String? name, Color? color}) =>
      _changing(() => _api.updateCalendar(_id(calendar), name: name, color: color));

  Future<void> setNotify(cal.CalendarInfo calendar, bool notify) =>
      _changing(() => _api.updateCalendar(_id(calendar), notify: notify));

  Future<void> makeDefault(cal.CalendarInfo calendar) => _changing(() => _api.setDefaultCalendar(_id(calendar)));

  Future<void> remove(cal.CalendarInfo calendar) => _changing(() => _api.deleteCalendar(_id(calendar)));

  Future<cal.CalendarInfo> subscribe({
    required String url,
    required String name,
    required Color color,
    required int refreshSeconds,
  }) => _changing(
    () => _api.subscribeCalendar(_sourceId, url: url, name: name, color: color, refreshSeconds: refreshSeconds),
  );

  Future<void> setRefreshInterval(cal.CalendarInfo calendar, int seconds) =>
      _changing(() => _api.updateCalendar(_id(calendar), refreshSeconds: seconds));

  Future<void> refresh(cal.CalendarInfo calendar) => _changing(() => _api.refreshCalendar(_id(calendar)));

  Future<CalendarImportResult> importInto(cal.CalendarInfo calendar, Uint8List content) =>
      _changing(() => _api.importCalendar(_id(calendar), content));

  Future<CalendarImportResult> importFile({required String name, required Color color, required Uint8List content}) =>
      _changing(() async {
        final created = await _api.createCalendar(_sourceId, name: name, color: color);
        return _api.importCalendar(_id(created), content);
      });
}

final calendarSharesProvider = AsyncNotifierProvider.autoDispose
    .family<CalendarSharesNotifier, List<CalendarShare>, int>(CalendarSharesNotifier.new);

class CalendarSharesNotifier extends AsyncNotifier<List<CalendarShare>> {
  CalendarSharesNotifier(this.calendarId);

  final int calendarId;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<CalendarShare>> build() => ref.watch(polderApiProvider).calendarShares(calendarId);

  Future<void> add(ShareTarget target, CalendarShareAccess access) async {
    final share = await _api.shareCalendar(calendarId, target, access);
    state = AsyncData([...?state.value?.where((existing) => existing.id != share.id), share]);
  }

  Future<void> change(CalendarShare share, CalendarShareAccess access) async {
    await _api.updateCalendarShare(calendarId, share.id, access);
    state = AsyncData([
      for (final existing in state.value ?? const <CalendarShare>[])
        existing.id == share.id ? existing.copyWith(access: access) : existing,
    ]);
  }

  Future<void> remove(CalendarShare share) async {
    await _api.removeCalendarShare(calendarId, share.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != share.id)]);
  }
}

final calendarSidebarSectionsProvider = NotifierProvider<CalendarSidebarSections, Set<String>>(
  CalendarSidebarSections.new,
);

class CalendarSidebarSections extends Notifier<Set<String>> {
  static const _key = "polder.calendar.collapsed";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final saved = (await _preferences.readJson(_key))?["sections"];
    if (ref.mounted && saved is List) state = {for (final section in saved) "$section"};
  }

  Future<void> toggle(String section) async {
    state = state.contains(section) ? ({...state}..remove(section)) : {...state, section};
    await _preferences.writeJson(_key, {"sections": state.toList()});
  }
}

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
