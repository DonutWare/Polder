import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/util/ref_cache.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/search_syntax.dart";

sealed class NotesView {
  const NotesView();
}

class AllNotes extends NotesView {
  const AllNotes();
}

class UntaggedNotes extends NotesView {
  const UntaggedNotes();
}

class TaggedNotes extends NotesView {
  const TaggedNotes(this.tagIds);

  final Set<int> tagIds;
}

final notesTagFilterProvider = NotifierProvider<NotesTagFilter, NotesView>(NotesTagFilter.new);

class NotesTagFilter extends Notifier<NotesView> {
  @override
  NotesView build() {
    final known = ref.watch(tagsByIdProvider);
    return switch (stateOrNull) {
      TaggedNotes(:final tagIds) => _tagged(tagIds.where(known.containsKey).toSet()),
      final view? => view,
      null => const AllNotes(),
    };
  }

  static NotesView _tagged(Set<int> tagIds) => tagIds.isEmpty ? const AllNotes() : TaggedNotes(tagIds);

  void showAll() => state = const AllNotes();

  void showUntagged() => state = const UntaggedNotes();

  void only(int tagId) => state = TaggedNotes({tagId});

  void toggle(int tagId) {
    final current = switch (state) {
      TaggedNotes(:final tagIds) => tagIds,
      _ => const <int>{},
    };
    state = _tagged(current.contains(tagId) ? ({...current}..remove(tagId)) : {...current, tagId});
  }
}

final notesIndexProvider = FutureProvider.autoDispose<List<FileEntry>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  ref.watch(tagsProvider);
  ref.listen(filesChangedProvider, (_, _) => ref.invalidateSelf());
  final root = await ref.watch(notesFolderProvider.future);
  if (root == null) return const [];
  return _notesIn(ref, root);
});

typedef NotesTagCounts = ({int total, int untagged, Map<int, int> byTag});

final notesTagCountsProvider = FutureProvider.autoDispose<NotesTagCounts>((ref) async {
  final notes = await ref.watch(notesIndexProvider.future);
  final byTag = <int, int>{};
  for (final note in notes) {
    for (final id in note.tagIds) {
      byTag[id] = (byTag[id] ?? 0) + 1;
    }
  }
  return (total: notes.length, untagged: notes.where(isUntagged).length, byTag: byTag);
});

final notesInViewProvider = FutureProvider.autoDispose<List<FileEntry>?>((ref) async {
  final view = ref.watch(notesTagFilterProvider);
  if (view is AllNotes) return null;
  final notes = await ref.watch(notesIndexProvider.future);
  return notesMatching(view, notes);
});

List<FileEntry> notesMatching(NotesView view, List<FileEntry> notes) => [
  for (final note in notes)
    if (switch (view) {
      AllNotes() => true,
      UntaggedNotes() => isUntagged(note),
      TaggedNotes(:final tagIds) => note.tagIds.any(tagIds.contains),
    })
      note,
];

const _pageSize = 200;
const _maxIndexedNotes = 2000;

Future<List<FileEntry>> _notesIn(Ref ref, String root) async {
  final api = ref.read(polderApiProvider);
  final query = notesFolderQuery(root);
  final found = <FileEntry>[];
  while (found.length < _maxIndexedNotes) {
    final page = await api.search(query, limit: _pageSize, offset: found.length);
    found.addAll(page.hits.map((hit) => hit.entry));
    if (page.hits.length < _pageSize) break;
  }
  return [
    for (final entry in found)
      if (!entry.isDir && RemotePath.isWithin(entry.path, root)) entry,
  ]..sort((a, b) => noteTitleOf(a).toLowerCase().compareTo(noteTitleOf(b).toLowerCase()));
}

String notesFolderQuery(String root) => "type=md in=${quoteSearchValue(root)}";

bool isUntagged(FileEntry note) => note.tagIds.isEmpty && note.otherTags.isEmpty;

String noteTitleOf(FileEntry entry) {
  final name = RemotePath.withoutExtension(entry.name);
  return name.toLowerCase() == "readme" ? RemotePath.name(RemotePath.parent(entry.path)) : name;
}

Color? noteTintOf(Map<int, UserTag> tags, FileEntry entry) =>
    entry.tagIds.map((id) => tags[id]).nonNulls.firstOrNull?.color;
