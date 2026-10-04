import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/providers/account_provider.dart";
import "package:nomad/services/sync/sync_activity.dart";

final syncActivityProvider = Provider<SyncActivity>((ref) {
  ref.watch(currentAccountProvider.select((account) => account?.id));
  final activity = SyncActivity();
  ref.onDispose(activity.dispose);
  return activity;
});

final localSyncItemsProvider = NotifierProvider<LocalSyncItemsNotifier, Map<String, LocalSyncItem>>(
  LocalSyncItemsNotifier.new,
);

class LocalSyncItemsNotifier extends Notifier<Map<String, LocalSyncItem>> {
  @override
  Map<String, LocalSyncItem> build() {
    final activity = ref.watch(syncActivityProvider);
    final subscription = activity.changes.listen((items) => state = items);
    ref.onDispose(subscription.cancel);
    return activity.items;
  }
}
