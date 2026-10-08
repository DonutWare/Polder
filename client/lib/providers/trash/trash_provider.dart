import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/browser/directory_provider.dart";
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

  Future<FileEntry> restore(TrashItem item, {RestoreMode onConflict = RestoreMode.fail}) async {
    final restored = await _api.restoreFromTrash(item.id, onConflict: onConflict);
    ref.invalidate(directoryProvider(RemotePath.parent(restored.path)));
    ref.invalidate(currentUserProvider);
    ref.read(syncSchedulerProvider)?.requestRun();
    await refresh();
    return restored;
  }

  Future<void> delete(TrashItem item) async {
    await _api.deleteFromTrash(item.id);
    await refresh();
  }

  Future<void> empty() async {
    await _api.emptyTrash();
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
