import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";

abstract interface class SyncStateStore {
  Future<List<SyncRoot>> roots();

  Future<void> saveRoot(SyncRoot root);

  Future<void> deleteRoot(String rootId);

  Future<Map<String, SyncEntry>> entries(String rootId);

  Future<void> saveEntry(SyncEntry entry);

  Future<void> deleteEntryTree(String rootId, String relativePath);

  Future<int> cursor(String rootId);

  Future<void> saveCursor(String rootId, int cursor);

  Future<void> close();
}
