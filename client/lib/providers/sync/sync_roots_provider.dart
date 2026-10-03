import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/services/sync/sync_state_store.dart";

final syncRootsProvider = AsyncNotifierProvider<SyncRootsNotifier, List<SyncRoot>>(SyncRootsNotifier.new);

final syncRootsByModeProvider = Provider.family<List<SyncRoot>, SyncMode>(
  (ref, mode) => (ref.watch(syncRootsProvider).value ?? []).where((root) => root.mode == mode).toList(),
);

class SyncRootsNotifier extends AsyncNotifier<List<SyncRoot>> {
  Future<SyncStateStore> get _store => ref.read(syncStoreProvider.future);

  String? get _accountId => ref.read(currentAccountProvider)?.id;

  @override
  Future<List<SyncRoot>> build() async {
    final accountId = await ref.watch(accountProvider.selectAsync((account) => account?.id));
    final store = await ref.watch(syncStoreProvider.future);
    return (await store.roots()).where((root) => root.accountId == accountId).toList();
  }

  Future<void> add({required String localPath, required String remotePath, required SyncMode mode}) async {
    final accountId = _accountId;
    if (accountId == null) return;
    final root = SyncRoot(
      id: "${DateTime.now().microsecondsSinceEpoch}",
      accountId: accountId,
      localPath: localPath,
      remotePath: remotePath,
      mode: mode,
    );
    await (await _store).saveRoot(root);
    state = AsyncData([...?state.value, root]);
  }

  Future<void> setEnabled(SyncRoot root, bool enabled) async {
    final updated = root.copyWith(enabled: enabled);
    await (await _store).saveRoot(updated);
    state = AsyncData([
      for (final existing in state.value ?? <SyncRoot>[]) existing.id == root.id ? updated : existing,
    ]);
  }

  Future<void> remove(SyncRoot root) async {
    await (await _store).deleteRoot(root.id);
    state = AsyncData((state.value ?? []).where((existing) => existing.id != root.id).toList());
  }
}
