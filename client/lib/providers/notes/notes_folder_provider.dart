import "dart:async";
import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/util/guarded_refresh.dart";

final notesFolderProvider = AsyncNotifierProvider<NotesFolderNotifier, String?>(NotesFolderNotifier.new);

class NotesFolderNotifier extends AsyncNotifier<String?> with GuardedRefresh {
  static const _cacheKey = "notes.folder";

  @override
  Future<String?> build() async {
    ref.watch(polderApiProvider);
    await ref.watch(offlineStoreProvider.future);
    return localFirst(local: _cached, remote: _fetch);
  }

  Future<void> choose(String? path) async {
    final saved = await ref.read(polderApiProvider).setNotesFolder(path);
    await _remember(await ref.read(offlineStoreProvider.future), saved);
    settle(saved);
  }

  Future<String?> _cached() async {
    final cached = await (await ref.read(offlineStoreProvider.future)).meta(_cacheKey);
    return cached == null ? null : (jsonDecode(cached) as Map<String, dynamic>)["path"] as String?;
  }

  Future<String?> _fetch() async {
    final folder = await ref.read(polderApiProvider).notesFolder();
    await _remember(await ref.read(offlineStoreProvider.future), folder);
    return folder;
  }

  Future<void> _remember(OfflineStore store, String? folder) => store.saveMeta(_cacheKey, jsonEncode({"path": folder}));
}

final notesOfflinePinProvider = Provider<void>((ref) {
  final folder = ref.watch(notesFolderProvider);
  final files = ref.watch(offlineFilesProvider).value;
  if (files == null || !folder.hasValue) return;
  unawaited(files.pinNotes(folder.value));
});
