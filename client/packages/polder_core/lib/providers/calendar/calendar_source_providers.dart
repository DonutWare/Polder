import "dart:async";

import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/server_event.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/realtime/events_provider.dart";
import "package:polder_core/services/calendar/offline_calendar_source.dart";
import "package:polder_core/services/offline/offline_files.dart";
import "package:polder_core/services/calendar/polder_calendar_source.dart";
import "package:calendar_views/calendar_views.dart" as cal;

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

final offlineCalendarSourceProvider = Provider<OfflineCalendarSource?>((ref) {
  final remote = ref.watch(polderCalendarSourceProvider);
  if (remote == null) return null;
  final source = OfflineCalendarSource(
    remote: remote,
    api: ref.watch(polderApiProvider),
    store: ref.watch(offlineStoreProvider.future),
    onQueued: () => ref.read(offlineSyncProvider.notifier).request(OfflineWork.push),
    prefetchNearbyOnly: kIsWeb,
  );
  ref.onDispose(() => unawaited(source.dispose()));
  return source;
});

final polderCalendarSourcesOverride = cal.calendarSourcesProvider.overrideWith((ref) {
  final source = ref.watch(offlineCalendarSourceProvider);
  return [?source];
});
