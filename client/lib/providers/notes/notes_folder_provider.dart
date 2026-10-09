import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/polder_api_provider.dart";

final notesFolderProvider = AsyncNotifierProvider<NotesFolderNotifier, String?>(NotesFolderNotifier.new);

class NotesFolderNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => ref.watch(polderApiProvider).notesFolder();

  Future<void> choose(String? path) async {
    final saved = await ref.read(polderApiProvider).setNotesFolder(path);
    state = AsyncData(saved);
  }
}
