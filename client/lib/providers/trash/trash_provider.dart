import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/trash.dart";
import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/providers/current_user_provider.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/sync/sync_scheduler_provider.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/util/remote_path.dart";

final trashProvider = AsyncNotifierProvider.autoDispose<TrashNotifier, TrashListing>(TrashNotifier.new);

class TrashNotifier extends AsyncNotifier<TrashListing> {
  NomadApi get _api => ref.read(nomadApiProvider);

  @override
  Future<TrashListing> build() => ref.watch(nomadApiProvider).listTrash();

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
  Future<TrashRetention> build() => ref.watch(nomadApiProvider).trashRetention();

  Future<void> choose(int? days) async {
    state = AsyncData(await ref.read(nomadApiProvider).setTrashRetention(days));
    ref.invalidate(trashProvider);
  }
}
