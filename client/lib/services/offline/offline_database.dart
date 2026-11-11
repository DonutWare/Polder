import "package:drift/drift.dart";

class OfflineDatabase extends GeneratedDatabase {
  OfflineDatabase(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) => _createMissingTables(),
    onUpgrade: (_, from, _) async {
      if (from < 2) await _addFileColumns();
    },
    beforeOpen: (_) => _createMissingTables(),
  );

  Future<void> _addFileColumns() async {
    for (final column in ["size", "ready", "is_dir"]) {
      await customStatement("ALTER TABLE files ADD COLUMN $column INTEGER NOT NULL DEFAULT 0");
    }
    await customStatement("""
      UPDATE files SET
        size = coalesce(json_extract(json, '\$.entry.size'), 0),
        is_dir = coalesce(json_extract(json, '\$.entry.isDir'), 0),
        ready = CASE
          WHEN json_extract(json, '\$.localHash') IS NULL THEN 0
          WHEN state != 'synced' THEN 1
          WHEN json_extract(json, '\$.localHash') = json_extract(json, '\$.entry.hash') THEN 1
          ELSE 0
        END
      """);
  }

  Future<void> _createMissingTables() async {
    for (final statement in _schema) {
      await customStatement(statement);
    }
  }

  static const _schema = [
    """
    CREATE TABLE IF NOT EXISTS files (
      path TEXT PRIMARY KEY NOT NULL,
      parent TEXT NOT NULL,
      state TEXT NOT NULL,
      size INTEGER NOT NULL DEFAULT 0,
      ready INTEGER NOT NULL DEFAULT 0,
      is_dir INTEGER NOT NULL DEFAULT 0,
      json TEXT NOT NULL
    )
    """,
    "CREATE INDEX IF NOT EXISTS files_parent ON files (parent)",
    "CREATE INDEX IF NOT EXISTS files_missing ON files (ready, is_dir, size)",
    "CREATE INDEX IF NOT EXISTS files_state ON files (state)",
    """
    CREATE TABLE IF NOT EXISTS outbox (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      domain TEXT NOT NULL,
      path TEXT NOT NULL,
      json TEXT NOT NULL
    )
    """,
    "CREATE INDEX IF NOT EXISTS outbox_path ON outbox (path)",
    """
    CREATE TABLE IF NOT EXISTS pins (
      path TEXT PRIMARY KEY NOT NULL,
      json TEXT NOT NULL
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS meta (
      key TEXT PRIMARY KEY NOT NULL,
      value TEXT NOT NULL
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS blob_chunks (
      hash TEXT NOT NULL,
      idx INTEGER NOT NULL,
      bytes BLOB NOT NULL,
      PRIMARY KEY (hash, idx)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS calendar_events (
      key TEXT PRIMARY KEY NOT NULL,
      series_key TEXT NOT NULL,
      calendar_id TEXT NOT NULL,
      start_ms INTEGER NOT NULL,
      end_ms INTEGER NOT NULL,
      state TEXT NOT NULL,
      json TEXT NOT NULL
    )
    """,
    "CREATE INDEX IF NOT EXISTS calendar_events_range ON calendar_events (start_ms, end_ms)",
    "CREATE INDEX IF NOT EXISTS calendar_events_series ON calendar_events (series_key)",
    """
    CREATE TABLE IF NOT EXISTS calendar_months (
      month TEXT PRIMARY KEY NOT NULL,
      fetched_ms INTEGER NOT NULL
    )
    """,
  ];
}
