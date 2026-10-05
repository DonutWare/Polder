import "package:polder/models/sync/sync_entry.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/services/sync/sync_state_store.dart";
import "package:polder/util/relative_path.dart";

class InMemorySyncStateStore implements SyncStateStore {
  final Map<String, SyncRoot> _roots = {};
  final Map<String, Map<String, SyncEntry>> _entries = {};
  final Map<String, int> _cursors = {};

  @override
  Future<List<SyncRoot>> roots() async => _roots.values.toList();

  @override
  Future<void> saveRoot(SyncRoot root) async => _roots[root.id] = root;

  @override
  Future<void> deleteRoot(String rootId) async {
    _roots.remove(rootId);
    _entries.remove(rootId);
    _cursors.remove(rootId);
  }

  @override
  Future<Map<String, SyncEntry>> entries(String rootId) async => Map.of(_entries[rootId] ?? {});

  @override
  Future<void> saveEntry(SyncEntry entry) async => (_entries[entry.syncRootId] ??= {})[entry.relativePath] = entry;

  @override
  Future<void> saveEntries(Iterable<SyncEntry> entries) async {
    for (final entry in entries) {
      await saveEntry(entry);
    }
  }

  @override
  Future<void> deleteEntryTree(String rootId, String relativePath) async =>
      _entries[rootId]?.removeWhere((path, _) => path == relativePath || RelativePath.isWithin(path, relativePath));

  @override
  Future<int> cursor(String rootId) async => _cursors[rootId] ?? 0;

  @override
  Future<void> saveCursor(String rootId, int cursor) async => _cursors[rootId] = cursor;

  @override
  Future<void> close() async {}
}
