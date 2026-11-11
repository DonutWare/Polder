import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/providers/connection/server_connection_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/services/offline/sync_lane.dart";

final offlineSyncProvider = NotifierProvider<OfflineSyncNotifier, void>(OfflineSyncNotifier.new);

class OfflineSyncNotifier extends Notifier<void> {
  static const interval = Duration(minutes: 5);
  static const watchdog = Duration(minutes: 10);

  final _lanes = <OfflineWork, SyncLane>{};

  @override
  void build() {
    final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
    _lanes.clear();
    if (accountId == null) return;
    final conditions = ref.read(deviceConditionsProvider);
    Future<bool> hasNetwork() => conditions.hasNetwork();
    _lanes.addAll({
      OfflineWork.push: SyncLane(_push, watchdog: watchdog, canRun: hasNetwork),
      OfflineWork.pull: SyncLane(_pull, watchdog: watchdog, canRun: hasNetwork),
      OfflineWork.mirror: SyncLane(_mirror, debounce: const Duration(seconds: 1), canRun: hasNetwork),
    });
    final lanes = [..._lanes.values];
    final subscriptions = [
      conditions.networkChanges().listen((available) {
        if (available) kickAll();
      }),
    ];
    final periodic = Timer.periodic(interval, (_) => kick());
    ref.onDispose(() {
      periodic.cancel();
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
      for (final lane in lanes) {
        lane.dispose();
      }
    });
    ref.listen(serverConnectionProvider.select((connection) => connection.isOnline), (wasOnline, isOnline) {
      if (isOnline && wasOnline != true) kickAll();
    });
    ref.listen(filesChangedProvider, (_, _) => request(OfflineWork.pull));
    kickAll();
  }

  void request(OfflineWork work) => _lanes[work]?.kick();

  void kick() {
    request(OfflineWork.push);
    request(OfflineWork.pull);
  }

  void kickAll() {
    for (final lane in _lanes.values) {
      lane.kick();
    }
  }

  Future<void> pushNow() => _lanes[OfflineWork.push]?.run() ?? Future.value();

  Future<void> retryNow() async {
    final files = await ref.read(offlineFilesProvider.future);
    await files.retryNow();
    await ref.read(offlineCalendarSourceProvider)?.retryNow();
    for (final lane in _lanes.values) {
      lane.kick(delay: Duration.zero);
    }
  }

  Future<DateTime?> _push() async {
    final files = await ref.read(offlineFilesProvider.future);
    final filesRetry = await files.push();
    final calendarRetry = await ref.read(offlineCalendarSourceProvider)?.push();
    return _earliest(filesRetry, calendarRetry);
  }

  Future<DateTime?> _pull() async {
    final files = await ref.read(offlineFilesProvider.future);
    await files.pull();
    await ref.read(offlineCalendarSourceProvider)?.prefetch();
    return null;
  }

  Future<DateTime?> _mirror() async => (await ref.read(offlineFilesProvider.future)).mirror();

  static DateTime? _earliest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }
}
