import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/storage/preferences_store.dart";

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

enum NotesSortField { name, modified }

class NotesSort {
  const NotesSort({this.field = NotesSortField.name, this.ascending = true});

  final NotesSortField field;
  final bool ascending;

  bool get isDefault => field == NotesSortField.name && ascending;

  Map<String, Object> toJson() => {"field": field.name, "ascending": ascending};

  static NotesSort? fromJson(Map<String, dynamic>? json) {
    final field = NotesSortField.values.asNameMap()[json?["field"]];
    final ascending = json?["ascending"];
    if (field == null || ascending is! bool) return null;
    return NotesSort(field: field, ascending: ascending);
  }

  @override
  bool operator ==(Object other) => other is NotesSort && other.field == field && other.ascending == ascending;

  @override
  int get hashCode => Object.hash(field, ascending);
}

final notesSortProvider = NotifierProvider<NotesSortNotifier, NotesSort>(NotesSortNotifier.new);

class NotesSortNotifier extends Notifier<NotesSort> {
  static const _key = "polder.notes.sort";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  var _chosen = false;

  @override
  NotesSort build() {
    _load();
    return const NotesSort();
  }

  Future<void> _load() async {
    final saved = NotesSort.fromJson(await _preferences.readJson(_key));
    if (ref.mounted && !_chosen && saved != null) state = saved;
  }

  Future<void> select(NotesSortField field) =>
      _save(NotesSort(field: field, ascending: field == state.field ? state.ascending : field == NotesSortField.name));

  Future<void> setAscending(bool ascending) => _save(NotesSort(field: state.field, ascending: ascending));

  Future<void> _save(NotesSort sort) async {
    _chosen = true;
    state = sort;
    await _preferences.writeJson(_key, sort.toJson());
  }
}

List<NoteTreeNode> sortNoteNodes(List<NoteTreeNode> nodes, NotesSort sort) {
  if (sort.isDefault) return nodes;
  return [...nodes]..sort((a, b) => _compareNotes((a.name, _modifiedOf(a)), (b.name, _modifiedOf(b)), sort));
}

List<FileEntry> sortNoteEntries(List<FileEntry> notes, NotesSort sort) {
  if (sort.isDefault) return notes;
  return [...notes]..sort((a, b) => _compareNotes((noteTitleOf(a), a.mtime), (noteTitleOf(b), b.mtime), sort));
}

DateTime _modifiedOf(NoteTreeNode node) {
  final page = node.page?.mtime;
  final folder = node.folder?.mtime;
  if (page == null) return folder!;
  if (folder == null) return page;
  return page.isAfter(folder) ? page : folder;
}

int _compareNotes((String, DateTime) a, (String, DateTime) b, NotesSort sort) {
  final byName = a.$1.toLowerCase().compareTo(b.$1.toLowerCase());
  final primary = sort.field == NotesSortField.modified ? a.$2.compareTo(b.$2) : byName;
  final directed = sort.ascending ? primary : -primary;
  return directed != 0 ? directed : byName;
}

final notesSubpagesShownProvider = NotifierProvider<NotesSubpagesShown, bool>(NotesSubpagesShown.new);

class NotesSubpagesShown extends Notifier<bool> {
  static const _key = "polder.notes.subpages";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  var _chosen = false;

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final saved = (await _preferences.readJson(_key))?["shown"];
    if (ref.mounted && !_chosen && saved is bool) state = saved;
  }

  Future<void> toggle() async {
    _chosen = true;
    state = !state;
    await _preferences.writeJson(_key, {"shown": state});
  }
}

final notesRevealProvider = NotifierProvider<NotesReveal, String?>(NotesReveal.new);

class NotesReveal extends Notifier<String?> {
  @override
  String? build() => null;

  void reveal(String path) => state = path;

  void done() => state = null;
}
