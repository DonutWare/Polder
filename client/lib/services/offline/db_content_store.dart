import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:drift/drift.dart";

import "package:polder/services/offline/content_store.dart";
import "package:polder/services/offline/offline_database.dart";

class DbContentStore implements OfflineContentStore {
  DbContentStore(this._db);

  static const chunkSize = 1024 * 1024;
  static const _pendingPrefix = "pending-";

  final OfflineDatabase _db;
  var _pendingCounter = 0;

  @override
  Future<String> write(Uint8List bytes) => writeStream(Stream.value(bytes));

  @override
  Future<String> writeStream(Stream<List<int>> bytes) async {
    final pending = "$_pendingPrefix${DateTime.now().microsecondsSinceEpoch}-${_pendingCounter++}";
    final digest = _DigestSink();
    final hasher = sha256.startChunkedConversion(digest);
    final buffer = BytesBuilder(copy: false);
    var index = 0;
    try {
      await for (final chunk in bytes) {
        hasher.add(chunk);
        buffer.add(chunk);
        if (buffer.length >= chunkSize) await _insertChunk(pending, index++, buffer.takeBytes());
      }
      if (buffer.isNotEmpty || index == 0) await _insertChunk(pending, index, buffer.takeBytes());
      hasher.close();
    } on Object {
      await _deleteHash(pending);
      rethrow;
    }
    final hash = digest.value.toString();
    await _db.transaction(() async {
      if (await contains(hash)) {
        await _deleteHash(pending);
      } else {
        await _db.customUpdate(
          "UPDATE blob_chunks SET hash = ? WHERE hash = ?",
          variables: [Variable.withString(hash), Variable.withString(pending)],
        );
      }
    });
    return hash;
  }

  @override
  Future<Uint8List?> read(String hash) async {
    if (!await contains(hash)) return null;
    final builder = BytesBuilder(copy: false);
    await openRead(hash).forEach(builder.add);
    return builder.takeBytes();
  }

  @override
  Stream<List<int>> openRead(String hash) async* {
    if (!await contains(hash)) throw MissingContentException(hash);
    for (var index = 0; ; index++) {
      final row = await _db
          .customSelect(
            "SELECT bytes FROM blob_chunks WHERE hash = ? AND idx = ?",
            variables: [Variable.withString(hash), Variable.withInt(index)],
          )
          .getSingleOrNull();
      if (row == null) return;
      yield row.read<Uint8List>("bytes");
    }
  }

  @override
  Future<int?> length(String hash) async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS chunks, COALESCE(SUM(length(bytes)), 0) AS size FROM blob_chunks WHERE hash = ?",
          variables: [Variable.withString(hash)],
        )
        .getSingle();
    return row.read<int>("chunks") == 0 ? null : row.read<int>("size");
  }

  Future<bool> contains(String hash) async => await length(hash) != null;

  @override
  Future<void> retainOnly(Set<String> hashes) async {
    final rows = await _db.customSelect("SELECT DISTINCT hash FROM blob_chunks").get();
    for (final hash in rows.map((row) => row.read<String>("hash"))) {
      if (hash.startsWith(_pendingPrefix) || hashes.contains(hash)) continue;
      await _deleteHash(hash);
    }
  }

  Future<void> _insertChunk(String hash, int index, Uint8List bytes) => _db.customInsert(
    "INSERT INTO blob_chunks (hash, idx, bytes) VALUES (?, ?, ?)",
    variables: [Variable.withString(hash), Variable.withInt(index), Variable.withBlob(bytes)],
  );

  Future<void> _deleteHash(String hash) =>
      _db.customUpdate("DELETE FROM blob_chunks WHERE hash = ?", variables: [Variable.withString(hash)]);
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
