import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/services/sync/sync_platform.dart";
import "package:polder/services/sync/sync_platform_factory.dart";
import "package:polder/services/sync/sync_service.dart";
import "package:polder/services/sync/sync_state_store.dart";

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
        api: ref.watch(polderApiProvider),
        store: store,
        deviceName: ref.watch(deviceNameProvider),
        activity: ref.watch(syncActivityProvider),
      );
});
