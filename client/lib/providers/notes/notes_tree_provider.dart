import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/note_item.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/offline_files.dart";
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
    final files = await ref.watch(offlineFilesProvider.future);
    Timer? localRefresh;
    final subscription = files.changes.listen((_) {
      localRefresh?.cancel();
      localRefresh = Timer(localRefreshDelay, () async {
        if (await files.availableOffline(path)) await refresh();
      });
    });
    ref.onDispose(() {
      localRefresh?.cancel();
      unawaited(subscription.cancel());
    });
    return _fetch(ref.watch(polderApiProvider), files);
  }

  static const localRefreshDelay = Duration(milliseconds: 150);

  Future<void> refresh() async {
    final files = await ref.read(offlineFilesProvider.future);
    if (!ref.mounted) return;
    await refreshWith(() => _fetch(ref.read(polderApiProvider), files), keepOnError: true);
  }

  Future<NotesFolderContents> _fetch(PolderApi api, OfflineFiles files) async {
    if (await files.availableOffline(path)) return arrange(await localItems(files, path));
    return arrange(await api.listNotes(path));
  }

  static Future<List<NoteItem>> localItems(OfflineFiles files, String folder) async {
    final inside = <String, ({bool notes, bool readme})>{};
    for (final row in await files.tree(folder)) {
      if (!row.entry.isMarkdown) continue;
      final relative = RemotePath.relativeTo(row.path, folder);
      final slash = relative?.indexOf("/") ?? -1;
      if (relative == null || slash < 0) continue;
      final child = relative.substring(0, slash);
      final known = inside[child] ?? (notes: false, readme: false);
      inside[child] = _isReadme(relative.substring(slash + 1))
          ? (notes: known.notes, readme: true)
          : (notes: true, readme: known.readme);
    }
    return [
      for (final row in await files.children(folder))
        if (row.isDir || row.entry.isMarkdown)
          NoteItem(
            entry: row.entry,
            hasNotes: inside[row.entry.name]?.notes ?? false,
            hasReadme: inside[row.entry.name]?.readme ?? false,
          ),
    ];
  }

  static bool _isReadme(String notePath) => RemotePath.withoutExtension(notePath).toLowerCase() == "readme";

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

List<NoteTreeNode> walkNoteTree(
  String root, {
  required NotesFolderContents? Function(String folder) contentsOf,
  required bool Function(NoteTreeNode node) descend,
}) {
  final nodes = <NoteTreeNode>[];
  void walk(String folder) {
    for (final node in contentsOf(folder)?.nodes ?? const <NoteTreeNode>[]) {
      nodes.add(node);
      if (node.folder != null && node.hasChildren && descend(node)) walk(node.childrenPath);
    }
  }

  walk(root);
  return nodes;
}

List<NoteTreeNode> outermostNotes(Iterable<NoteTreeNode> nodes) => [
  for (final node in nodes)
    if (!nodes.any((other) => other != node && RemotePath.isWithin(node.path, other.childrenPath))) node,
];
