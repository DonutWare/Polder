import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/util/remote_path.dart";

final notesSearchQueryProvider = NotifierProvider<NotesSearchQuery, String>(NotesSearchQuery.new);

class NotesSearchQuery extends Notifier<String> {
  @override
  String build() => "";

  void set(String query) => state = query;

  void clear() => state = "";
}

class NotesTreeFilter {
  const NotesTreeFilter({required this.query, required this.matches, required this.folders});

  factory NotesTreeFilter.of(String query, String root, Iterable<FileEntry> notes) {
    final matches = {for (final note in notes) note.path};
    return NotesTreeFilter(query: query, matches: matches, folders: allNoteFolders(root, notes));
  }

  final String query;
  final Set<String> matches;
  final Set<String> folders;

  bool shows(NoteTreeNode node) => matches.contains(node.path) || folders.contains(node.childrenPath);

  bool opens(NoteTreeNode node) => folders.contains(node.childrenPath);
}

class NotesSearchResults {
  const NotesSearchResults({required this.notes, required this.filter});

  final List<FileEntry> notes;
  final NotesTreeFilter filter;
}

const notesContentSearchDelay = Duration(milliseconds: 300);
const _contentSearchLimit = 100;

final notesContentMatchesProvider = FutureProvider.autoDispose<List<FileEntry>>((ref) async {
  final query = ref.watch(notesSearchQueryProvider).trim();
  if (query.isEmpty) return const [];
  await Future<void>.delayed(notesContentSearchDelay);
  if (!ref.mounted) return const [];
  final root = await ref.watch(notesFolderProvider.future);
  if (root == null) return const [];
  try {
    final results = await ref
        .read(polderApiProvider)
        .search("${notesFolderQuery(root)} $query", limit: _contentSearchLimit);
    return [
      for (final hit in results.hits)
        if (!hit.entry.isDir && RemotePath.isWithin(hit.entry.path, root)) hit.entry,
    ];
  } on Exception {
    return const [];
  }
});

final notesSearchResultsProvider = FutureProvider.autoDispose<NotesSearchResults?>((ref) async {
  final query = ref.watch(notesSearchQueryProvider).trim();
  if (query.isEmpty) return null;
  final root = await ref.watch(notesFolderProvider.future);
  if (root == null) return null;
  final view = ref.watch(notesTagFilterProvider);
  final index = await ref.watch(notesIndexProvider.future);
  final content = ref.watch(notesContentMatchesProvider).value ?? const <FileEntry>[];
  final notes = notesMatching(view, mergeNoteMatches(titleMatches(index, query), content));
  return NotesSearchResults(notes: notes, filter: NotesTreeFilter.of(query, root, notes));
});

List<FileEntry> titleMatches(List<FileEntry> notes, String query) {
  final needle = query.toLowerCase();
  return [
    for (final note in notes)
      if (noteTitleOf(note).toLowerCase().contains(needle)) note,
  ];
}

List<FileEntry> mergeNoteMatches(List<FileEntry> titles, List<FileEntry> content) {
  final seen = {for (final note in titles) note.path};
  return [
    ...titles,
    for (final note in content)
      if (seen.add(note.path)) note,
  ];
}
