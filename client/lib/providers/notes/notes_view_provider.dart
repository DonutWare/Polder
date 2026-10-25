import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/service_providers.dart";
import "package:polder/services/storage/preferences_store.dart";

enum NotesViewMode { tree, grid }

final notesViewModeProvider = NotifierProvider<NotesViewModeNotifier, NotesViewMode>(NotesViewModeNotifier.new);

class NotesViewModeNotifier extends Notifier<NotesViewMode> {
  static const _key = "polder.notes.view";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  var _chosen = false;

  @override
  NotesViewMode build() {
    _load();
    return NotesViewMode.tree;
  }

  Future<void> _load() async {
    final saved = NotesViewMode.values.asNameMap()[(await _preferences.readJson(_key))?["mode"]];
    if (ref.mounted && !_chosen && saved != null) state = saved;
  }

  Future<void> toggle() async {
    _chosen = true;
    state = state == NotesViewMode.tree ? NotesViewMode.grid : NotesViewMode.tree;
    await _preferences.writeJson(_key, {"mode": state.name});
  }
}

final notesGridFolderProvider = NotifierProvider<NotesGridFolder, String?>(NotesGridFolder.new);

class NotesGridFolder extends Notifier<String?> {
  @override
  String? build() => null;

  void open(String? path) => state = path;
}
