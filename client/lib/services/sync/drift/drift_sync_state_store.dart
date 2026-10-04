import "dart:convert";

import "package:drift/drift.dart";

import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/sync/drift/sync_database.dart";
import "package:nomad/services/sync/sync_state_store.dart";

class DriftSyncStateStore implements SyncStateStore {
  DriftSyncStateStore(this._db);

  final SyncDatabase _db;

  @override
  Future<List<SyncRoot>> roots() async {
    final rows = await _db.customSelect("SELECT json FROM sync_roots").get();
    return rows.map((row) => SyncRoot.fromJson(jsonDecode(row.read<String>("json")) as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveRoot(SyncRoot root) => _db.customInsert(
    "INSERT OR REPLACE INTO sync_roots (id, json) VALUES (?, ?)",
    variables: [Variable.withString(root.id), Variable.withString(jsonEncode(root.toJson()))],
  );

  @override
  Future<void> deleteRoot(String rootId) => _db.transaction(() async {
    final id = [Variable.withString(rootId)];
    await _db.customUpdate("DELETE FROM sync_roots WHERE id = ?", variables: id);
    await _db.customUpdate("DELETE FROM sync_entries WHERE sync_root_id = ?", variables: id);
    await _db.customUpdate("DELETE FROM sync_cursors WHERE sync_root_id = ?", variables: id);
  });

  @override
  Future<Map<String, SyncEntry>> entries(String rootId) async {
    final rows = await _db
        .customSelect("SELECT * FROM sync_entries WHERE sync_root_id = ?", variables: [Variable.withString(rootId)])
        .get();
    return {for (final entry in rows.map(_entryFromRow)) entry.relativePath: entry};
  }

  @override
  Future<void> saveEntry(SyncEntry entry) => _db.customInsert(
    """
    INSERT OR REPLACE INTO sync_entries
      (sync_root_id, relative_path, is_dir, local_hash, local_size, local_mtime, synced_rev, synced_hash, manifest_json, state)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """,
    variables: [
      Variable.withString(entry.syncRootId),
      Variable.withString(entry.relativePath),
      Variable.withBool(entry.isDir),
      Variable<String>(entry.localHash),
      Variable<int>(entry.localSize),
      Variable<int>(entry.localMtime?.millisecondsSinceEpoch),
      Variable.withInt(entry.syncedRev),
      Variable.withString(entry.syncedHash),
      Variable<String>(entry.manifestJson),
      Variable.withString(entry.state.name),
    ],
  );

  @override
  Future<void> saveEntries(Iterable<SyncEntry> entries) => _db.transaction(() async {
    for (final entry in entries) {
      await saveEntry(entry);
    }
  });

  @override
  Future<void> deleteEntryTree(String rootId, String relativePath) => _db.customUpdate(
    "DELETE FROM sync_entries WHERE sync_root_id = ? AND (relative_path = ? OR substr(relative_path, 1, ?) = ?)",
    variables: [
      Variable.withString(rootId),
      Variable.withString(relativePath),
      Variable.withInt(relativePath.length + 1),
      Variable.withString("$relativePath/"),
    ],
  );

  @override
  Future<int> cursor(String rootId) async {
    final row = await _db
        .customSelect(
          "SELECT cursor FROM sync_cursors WHERE sync_root_id = ?",
          variables: [Variable.withString(rootId)],
        )
        .getSingleOrNull();
    return row?.read<int>("cursor") ?? 0;
  }

  @override
  Future<void> saveCursor(String rootId, int cursor) => _db.customInsert(
    "INSERT OR REPLACE INTO sync_cursors (sync_root_id, cursor) VALUES (?, ?)",
    variables: [Variable.withString(rootId), Variable.withInt(cursor)],
  );

  @override
  Future<void> close() => _db.close();

  SyncEntry _entryFromRow(QueryRow row) {
    final mtime = row.readNullable<int>("local_mtime");
    return SyncEntry(
      syncRootId: row.read<String>("sync_root_id"),
      relativePath: row.read<String>("relative_path"),
      isDir: row.read<bool>("is_dir"),
      localHash: row.readNullable<String>("local_hash"),
      localSize: row.readNullable<int>("local_size"),
      localMtime: mtime == null ? null : DateTime.fromMillisecondsSinceEpoch(mtime, isUtc: true),
      syncedRev: row.read<int>("synced_rev"),
      syncedHash: row.read<String>("synced_hash"),
      manifestJson: row.readNullable<String>("manifest_json"),
      state: EntryState.values.byName(row.read<String>("state")),
    );
  }
}
