import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/sync/sync_activity_provider.dart";
import "package:nomad/services/sync/sync_platform.dart";
import "package:nomad/services/sync/sync_platform_factory.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";

final syncPlatformProvider = Provider<SyncPlatform>((ref) => createSyncPlatform());

final syncStoreProvider = FutureProvider<SyncStateStore>((ref) async {
  final store = await ref.watch(syncPlatformProvider).openStore();
  ref.onDispose(store.close);
  return store;
});

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final store = await ref.watch(syncStoreProvider.future);
  return ref
      .watch(syncPlatformProvider)
      .createService(
        api: ref.watch(nomadApiProvider),
        store: store,
        deviceName: ref.watch(currentAccountProvider)?.deviceName ?? "",
        activity: ref.watch(syncActivityProvider),
      );
});
