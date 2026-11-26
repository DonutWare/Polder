import "package:drift/drift.dart";

class SyncDatabase extends GeneratedDatabase {
  SyncDatabase(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      for (final statement in _schema) {
        await customStatement(statement);
      }
    },
  );

  static const _schema = [
    """
    CREATE TABLE sync_roots (
      id TEXT PRIMARY KEY NOT NULL,
      json TEXT NOT NULL
    )
    """,
    """
    CREATE TABLE sync_entries (
      sync_root_id TEXT NOT NULL,
      relative_path TEXT NOT NULL,
      is_dir INTEGER NOT NULL DEFAULT 0,
      local_hash TEXT,
      local_size INTEGER,
      local_mtime INTEGER,
      synced_rev INTEGER NOT NULL DEFAULT 0,
      synced_hash TEXT NOT NULL DEFAULT '',
      manifest_json TEXT,
      state TEXT NOT NULL,
      PRIMARY KEY (sync_root_id, relative_path)
    )
    """,
    """
    CREATE TABLE sync_cursors (
      sync_root_id TEXT PRIMARY KEY NOT NULL,
      cursor INTEGER NOT NULL
    )
    """,
  ];
}
