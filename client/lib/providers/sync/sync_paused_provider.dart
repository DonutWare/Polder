import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/providers/service_providers.dart";
import "package:nomad/providers/sync/sync_activity_provider.dart";
import "package:nomad/providers/sync/sync_status_provider.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_pause.dart";

final syncPausedProvider = AsyncNotifierProvider<SyncPausedNotifier, bool>(SyncPausedNotifier.new);

class SyncPausedNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => SyncPause.read(ref.read(preferencesStoreProvider));

  Future<void> pause() async {
    await future;
    state = const AsyncData(true);
    ref.read(syncActivityProvider).cancelAll(CancelReason.paused);
    ref.read(syncStatusProvider.notifier).markPaused();
    await SyncPause.write(ref.read(preferencesStoreProvider), paused: true);
  }

  Future<void> resume() async {
    await future;
    state = const AsyncData(false);
    await SyncPause.write(ref.read(preferencesStoreProvider), paused: false);
    await ref.read(syncStatusProvider.notifier).syncNow();
  }
}
