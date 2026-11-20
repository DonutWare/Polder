import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/file_operations_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/remote_path.dart";

final trashProvider = AsyncNotifierProvider.autoDispose<TrashNotifier, TrashListing>(TrashNotifier.new);

class TrashNotifier extends AsyncNotifier<TrashListing> {
  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<TrashListing> build() => ref.watch(polderApiProvider).listTrash();

  Future<void> refresh() async => state = await AsyncValue.guard(_api.listTrash);

  FileOperationsNotifier get _operations => ref.read(fileOperationsProvider.notifier);

  static FileOperationItem _itemOf(TrashItem item) =>
      FileOperationItem(path: item.originalPath, isDir: item.isDir, label: item.name);

  Future<FileEntry> restore(TrashItem item, {RestoreMode onConflict = RestoreMode.fail}) async {
    final restored = await _operations.runSingle(
      kind: FileOperationKind.restore,
      item: _itemOf(item),
      ownFiles: false,
      perform: () => _api.restoreFromTrash(item.id, onConflict: onConflict),
    );
    ref.invalidate(directoryProvider(RemotePath.parent(restored.path)));
    ref.invalidate(currentUserProvider);
    ref.read(syncSchedulerProvider)?.requestRun();
    await refresh();
    return restored;
  }

  Future<void> delete(TrashItem item) async {
    await _operations.runSingle(
      kind: FileOperationKind.purge,
      item: _itemOf(item),
      ownFiles: false,
      perform: () => _api.deleteFromTrash(item.id),
    );
    await refresh();
  }

  Future<void> empty({required String label}) async {
    await _operations.runSingle(
      kind: FileOperationKind.purge,
      item: FileOperationItem(path: RemotePath.root, isDir: true, label: label),
      ownFiles: false,
      perform: _api.emptyTrash,
    );
    await refresh();
  }
}

final trashRetentionProvider = AsyncNotifierProvider.autoDispose<TrashRetentionNotifier, TrashRetention>(
  TrashRetentionNotifier.new,
);

class TrashRetentionNotifier extends AsyncNotifier<TrashRetention> {
  @override
  Future<TrashRetention> build() => ref.watch(polderApiProvider).trashRetention();

  Future<void> choose(TrashPreferences preferences) async {
    state = AsyncData(await ref.read(polderApiProvider).setTrashRetention(preferences));
    ref.invalidate(trashProvider);
  }
}
