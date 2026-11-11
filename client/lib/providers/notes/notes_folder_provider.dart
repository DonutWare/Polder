import "dart:async";
import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/offline/offline_store.dart";

final notesFolderProvider = AsyncNotifierProvider<NotesFolderNotifier, String?>(NotesFolderNotifier.new);

class NotesFolderNotifier extends AsyncNotifier<String?> {
  static const _cacheKey = "notes.folder";

  @override
  Future<String?> build() async {
    final api = ref.watch(polderApiProvider);
    final store = await ref.watch(offlineStoreProvider.future);
    try {
      final folder = await api.notesFolder();
      await _remember(store, folder);
      return folder;
    } on NetworkException {
      final cached = await store.meta(_cacheKey);
      if (cached == null) rethrow;
      return (jsonDecode(cached) as Map<String, dynamic>)["path"] as String?;
    }
  }

  Future<void> choose(String? path) async {
    final saved = await ref.read(polderApiProvider).setNotesFolder(path);
    await _remember(await ref.read(offlineStoreProvider.future), saved);
    state = AsyncData(saved);
  }

  Future<void> _remember(OfflineStore store, String? folder) => store.saveMeta(_cacheKey, jsonEncode({"path": folder}));
}

final notesOfflinePinProvider = Provider<void>((ref) {
  final folder = ref.watch(notesFolderProvider);
  final files = ref.watch(offlineFilesProvider).value;
  if (files == null || !folder.hasValue) return;
  unawaited(files.pinNotes(folder.value));
});
