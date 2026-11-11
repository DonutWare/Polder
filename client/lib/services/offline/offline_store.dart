import "dart:async";
import "dart:convert";

import "package:drift/drift.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/util/remote_path.dart";

typedef OfflineCounts = ({int files, int ready, int bytes, int readyBytes});

class OfflineStore {
  OfflineStore(this.db);

  final OfflineDatabase db;
  final _changes = StreamController<void>.broadcast();
  var _batchDepth = 0;
  var _changedInBatch = false;

  static const _cursorKey = "files.cursor";

  Stream<void> get changes => _changes.stream;

  Future<T> batch<T>(Future<T> Function() action) async {
    _batchDepth++;
    try {
      return await db.transaction(action);
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _changedInBatch) {
        _changedInBatch = false;
        _changes.add(null);
      }
    }
  }

  void _changed() {
    if (_batchDepth > 0) {
      _changedInBatch = true;
    } else if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  Future<OfflineFile?> file(String path) async {
    final row = await db
        .customSelect("SELECT json FROM files WHERE path = ?", variables: [Variable.withString(path)])
        .getSingleOrNull();
    return row == null ? null : _fileFromRow(row);
  }

  Future<List<OfflineFile>> children(String parent) => _files("SELECT json FROM files WHERE parent = ? AND path != ?", [
    Variable.withString(parent),
    Variable.withString(parent),
  ]);

  Future<List<OfflineFile>> tree(String root) => root == RemotePath.root
      ? _files("SELECT json FROM files", const [])
      : _files("SELECT json FROM files WHERE path = ? OR path LIKE ? ESCAPE '\\'", [
          Variable.withString(root),
          Variable.withString("${_escapeLike(root)}/%"),
        ]);

  Future<List<OfflineFile>> filesWithIds(Iterable<int> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value(const []);
    return _files(
      "SELECT json FROM files WHERE json_extract(json, '\$.entry.id') IN (${List.filled(list.length, "?").join(", ")})",
      [for (final id in list) Variable.withInt(id)],
    );
  }

  Future<List<OfflineFile>> unsyncedFiles() => _files("SELECT json FROM files WHERE state != 'synced'", const []);

  Future<void> saveFile(OfflineFile file) async {
    await _insertFile(file);
    _changed();
  }

  Future<void> deleteFile(String path) async {
    await db.customUpdate("DELETE FROM files WHERE path = ?", variables: [Variable.withString(path)]);
    _changed();
  }

  Future<void> deleteTree(String root) async {
    if (root == RemotePath.root) {
      await db.customUpdate("DELETE FROM files");
    } else {
      await db.customUpdate(
        "DELETE FROM files WHERE path = ? OR path LIKE ? ESCAPE '\\'",
        variables: [Variable.withString(root), Variable.withString("${_escapeLike(root)}/%")],
      );
    }
    _changed();
  }

  Future<Set<String>> referencedHashes() async {
    final rows = await db
        .customSelect("SELECT DISTINCT json_extract(json, '\$.localHash') AS hash FROM files WHERE hash IS NOT NULL")
        .get();
    return {
      for (final row in rows) row.read<String>("hash"),
      for (final entry in await outbox())
        if (entry.op case PutOp(:final hash)) hash,
    };
  }

  Future<OfflineCounts> counts(String root, {Iterable<String> skip = const []}) async {
    final (where, variables) = _scope(root, skip);
    final row = await db
        .customSelect(
          "SELECT count(*) AS files, coalesce(sum(ready), 0) AS ready, coalesce(sum(size), 0) AS bytes, "
          "coalesce(sum(size * ready), 0) AS ready_bytes FROM files WHERE is_dir = 0 AND $where",
          variables: variables,
        )
        .getSingle();
    return (
      files: row.read<int>("files"),
      ready: row.read<int>("ready"),
      bytes: row.read<int>("bytes"),
      readyBytes: row.read<int>("ready_bytes"),
    );
  }

  Future<List<OfflineFile>> missingContent(String root, {Iterable<String> skip = const [], int? maxSize, int? limit}) {
    final (where, variables) = _scope(root, skip);
    return _files(
      "SELECT json FROM files WHERE is_dir = 0 AND ready = 0 AND state = 'synced' AND $where"
      "${maxSize == null ? "" : " AND size <= $maxSize"} ORDER BY size${limit == null ? "" : " LIMIT $limit"}",
      variables,
    );
  }

  Future<List<OfflinePin>> pins() async {
    final rows = await db.customSelect("SELECT json FROM pins").get();
    return [for (final row in rows) OfflinePin.fromJson(jsonDecode(row.read<String>("json")) as Map<String, dynamic>)];
  }

  Future<void> savePin(OfflinePin pin) async {
    await db.customInsert(
      "INSERT OR REPLACE INTO pins (path, json) VALUES (?, ?)",
      variables: [Variable.withString(pin.path), Variable.withString(jsonEncode(pin.toJson()))],
    );
    _changed();
  }

  Future<void> deletePin(String path) async {
    await db.customUpdate("DELETE FROM pins WHERE path = ?", variables: [Variable.withString(path)]);
    _changed();
  }

  Future<int?> cursor() async => int.tryParse(await meta(_cursorKey) ?? "");

  Future<void> saveCursor(int? cursor) => saveMeta(_cursorKey, cursor?.toString());

  Future<String?> meta(String key) async {
    final row = await db
        .customSelect("SELECT value FROM meta WHERE key = ?", variables: [Variable.withString(key)])
        .getSingleOrNull();
    return row?.read<String>("value");
  }

  Future<void> saveMeta(String key, String? value) async {
    if (value == null) {
      await db.customUpdate("DELETE FROM meta WHERE key = ?", variables: [Variable.withString(key)]);
    } else {
      await db.customInsert(
        "INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)",
        variables: [Variable.withString(key), Variable.withString(value)],
      );
    }
  }

  Future<List<OutboxEntry>> outbox([OutboxDomain? domain]) async {
    final rows = domain == null
        ? await db.customSelect("SELECT id, json FROM outbox ORDER BY id").get()
        : await db
              .customSelect(
                "SELECT id, json FROM outbox WHERE domain = ? ORDER BY id",
                variables: [Variable.withString(domain.name)],
              )
              .get();
    return [for (final row in rows) _entryFromRow(row)];
  }

  Future<List<OutboxEntry>> outboxFor(String path) async => [
    for (final entry in await outbox(OutboxDomain.files))
      if (_touches(entry.op, path)) entry,
  ];

  Future<int> enqueue(OutboxOp op, {required DateTime at}) async {
    final entry = OutboxEntry(id: 0, op: op, createdAt: at);
    final id = await db.customInsert(
      "INSERT INTO outbox (domain, path, json) VALUES (?, ?, ?)",
      variables: [Variable.withString(op.domain.name), Variable.withString(op.path), _entryJson(entry)],
    );
    _changed();
    return id;
  }

  Future<void> saveEntry(OutboxEntry entry) async {
    await db.customUpdate(
      "UPDATE outbox SET path = ?, json = ? WHERE id = ?",
      variables: [Variable.withString(entry.path), _entryJson(entry), Variable.withInt(entry.id)],
    );
    _changed();
  }

  Future<void> removeEntry(int id) async {
    await db.customUpdate("DELETE FROM outbox WHERE id = ?", variables: [Variable.withInt(id)]);
    _changed();
  }

  Future<void> dispose() => _changes.close();

  Future<void> close() async {
    await dispose();
    await db.close();
  }

  static bool _touches(OutboxOp op, String path) => switch (op) {
    MoveOp(:final from, :final to) => _within(from, path) || _within(to, path),
    _ => _within(op.path, path),
  };

  static bool _within(String candidate, String root) => candidate == root || RemotePath.isWithin(candidate, root);

  Future<void> _insertFile(OfflineFile file) => db.customInsert(
    "INSERT OR REPLACE INTO files (path, parent, state, size, ready, is_dir, json) VALUES (?, ?, ?, ?, ?, ?, ?)",
    variables: [
      Variable.withString(file.path),
      Variable.withString(RemotePath.parent(file.path)),
      Variable.withString(file.state.name),
      Variable.withInt(file.entry.size),
      Variable.withBool(file.contentReady),
      Variable.withBool(file.isDir),
      Variable.withString(jsonEncode(file.toJson())),
    ],
  );

  Future<List<OfflineFile>> _files(String sql, List<Variable> variables) async => [
    for (final row in await db.customSelect(sql, variables: variables).get()) _fileFromRow(row),
  ];

  static OfflineFile _fileFromRow(QueryRow row) =>
      OfflineFile.fromJson(jsonDecode(row.read<String>("json")) as Map<String, dynamic>);

  static OutboxEntry _entryFromRow(QueryRow row) {
    final json = jsonDecode(row.read<String>("json")) as Map<String, dynamic>;
    return _entryFromJson(json).copyWith(id: row.read<int>("id"));
  }

  static OutboxEntry _entryFromJson(Map<String, dynamic> json) => OutboxEntry(
    id: 0,
    op: OutboxOp.fromJson(json["op"] as Map<String, dynamic>),
    createdAt: DateTime.parse(json["createdAt"] as String),
    attempts: json["attempts"] as int? ?? 0,
    nextAttemptAt: DateTime.tryParse(json["nextAttemptAt"] as String? ?? ""),
    error: switch (json["error"]) {
      final Map<String, dynamic> error => OutboxError.fromJson(error),
      _ => null,
    },
  );

  static Variable<String> _entryJson(OutboxEntry entry) => Variable.withString(
    jsonEncode({
      "op": entry.op.toJson(),
      "createdAt": entry.createdAt.toUtc().toIso8601String(),
      "attempts": entry.attempts,
      "nextAttemptAt": ?entry.nextAttemptAt?.toUtc().toIso8601String(),
      "error": ?entry.error?.toJson(),
    }),
  );

  static (String, List<Variable>) _scope(String root, Iterable<String> skip) {
    final clauses = <String>[];
    final variables = <Variable>[];
    void within(String path, {required bool negate}) {
      clauses.add("${negate ? "NOT " : ""}(path = ? OR path LIKE ? ESCAPE '\\')");
      variables.addAll([Variable.withString(path), Variable.withString("${_escapeLike(path)}/%")]);
    }

    if (root != RemotePath.root) within(root, negate: false);
    for (final path in skip) {
      within(path, negate: true);
    }
    return (clauses.isEmpty ? "1 = 1" : clauses.join(" AND "), variables);
  }

  static String _escapeLike(String value) =>
      value.replaceAll("\\", "\\\\").replaceAll("%", "\\%").replaceAll("_", "\\_");
}
