import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/note_item.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/guarded_refresh.dart";
import "package:polder/util/remote_path.dart";

class NoteTreeNode {
  const NoteTreeNode({this.page, this.folder, this.hasChildren = false});

  final FileEntry? page;
  final FileEntry? folder;
  final bool hasChildren;

  String get path => (page ?? folder)!.path;

  String get name => page != null ? RemotePath.withoutExtension(page!.name) : folder!.name;

  bool holds(String path) => path == page?.path || RemotePath.isWithin(path, childrenPath);

  String get childrenPath =>
      folder?.path ?? RemotePath.join(RemotePath.parent(page!.path), RemotePath.withoutExtension(page!.name));
}

class NotesFolderContents {
  const NotesFolderContents({required this.nodes, this.readme});

  final List<NoteTreeNode> nodes;
  final FileEntry? readme;
}

final _readme = RegExp(r"^readme\.(md|markdown)$", caseSensitive: false);

final notesTreeProvider = AsyncNotifierProvider.autoDispose.family<NotesTreeNotifier, NotesFolderContents, String>(
  NotesTreeNotifier.new,
);

class NotesTreeNotifier extends AsyncNotifier<NotesFolderContents> with GuardedRefresh {
  NotesTreeNotifier(this.path);

  static const refreshDelays = [Duration(milliseconds: 400), Duration(seconds: 2)];

  final String path;

  @override
  Future<NotesFolderContents> build() async {
    final timers = <Timer>[];
    ref.onDispose(() {
      for (final timer in timers) {
        timer.cancel();
      }
    });
    ref.listen(filesChangedProvider, (_, next) {
      final changed = next.value ?? const <String>[];
      if (!changed.any((folder) => folder == path || RemotePath.isWithin(folder, path))) return;
      for (final delay in refreshDelays) {
        timers.add(Timer(delay, refresh));
      }
    });
    return _fetch(ref.watch(polderApiProvider));
  }

  Future<void> refresh() => refreshWith(() => _fetch(ref.read(polderApiProvider)), keepOnError: true);

  Future<NotesFolderContents> _fetch(PolderApi api) async => arrange(await api.listNotes(path));

  static NotesFolderContents arrange(List<NoteItem> items) {
    final pages = <String, NoteItem>{};
    final folders = <String, NoteItem>{};
    FileEntry? readme;
    for (final item in items) {
      if (item.entry.isDir) {
        folders[item.entry.name] = item;
      } else if (_readme.hasMatch(item.entry.name)) {
        readme = item.entry;
      } else {
        pages[RemotePath.withoutExtension(item.entry.name)] = item;
      }
    }
    final nodes = [
      for (final MapEntry(key: name, value: page) in pages.entries)
        NoteTreeNode(page: page.entry, folder: folders[name]?.entry, hasChildren: folders[name]?.hasNotes ?? false),
      for (final MapEntry(key: name, value: folder) in folders.entries)
        if (!pages.containsKey(name) && (folder.hasNotes || folder.hasReadme))
          NoteTreeNode(folder: folder.entry, hasChildren: folder.hasNotes),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return NotesFolderContents(nodes: nodes, readme: readme);
  }
}
