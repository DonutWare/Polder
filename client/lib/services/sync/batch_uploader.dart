import "dart:io";
import "dart:typed_data";

import "package:polder/models/file_entry.dart";
import "package:polder/models/manifest.dart";
import "package:polder/models/sync/local_file_state.dart";
import "package:polder/models/upload_batch.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/chunker.dart";
import "package:polder/services/sync/sync_activity.dart";

class UploadTracking {
  const UploadTracking({required this.begin, required this.progress});

  final CancelToken Function(LocalSyncPhase phase, int? total) begin;
  final void Function(int bytes) progress;
}

class UploadResult {
  const UploadResult({required this.entry, required this.manifest});

  final FileEntry entry;
  final Manifest manifest;
}

class UploadItem {
  const UploadItem({
    required this.source,
    required this.remotePath,
    required this.local,
    required this.baseRev,
    this.manifest,
    this.tracking,
  });

  final File source;
  final String remotePath;
  final LocalFileState local;
  final int baseRev;
  final Manifest? manifest;
  final UploadTracking? tracking;
}

class UploadOutcome {
  const UploadOutcome.stored(this.item, UploadResult this.result) : error = null;

  const UploadOutcome.failed(this.item, Exception this.error) : result = null;

  final UploadItem item;
  final UploadResult? result;
  final Exception? error;
}

class BatchUploader {
  BatchUploader(this._api);

  final PolderApi _api;
  final Map<String, Set<String>> _pausedBatches = {};

  Future<List<UploadOutcome>> upload(List<UploadItem> items, {required String group, CancelToken? run}) async {
    final outcomes = <UploadItem, UploadOutcome>{};
    final prepared = <_PreparedItem>[];
    for (final item in items) {
      try {
        prepared.add(await _prepare(item));
      } on Exception catch (error) {
        outcomes[item] = UploadOutcome.failed(item, error);
      }
    }
    if (prepared.isNotEmpty) {
      for (final outcome in await _send(prepared, group, run)) {
        outcomes[outcome.item] = outcome;
      }
    }
    return [for (final item in items) outcomes[item]!];
  }

  Future<_PreparedItem> _prepare(UploadItem item) async {
    final manifest = item.manifest ?? _singleChunkManifest(item.local) ?? await _chunk(item);
    if (item.tracking != null) await _ensureUnchanged(item, manifest);
    return _PreparedItem(item, manifest);
  }

  Manifest? _singleChunkManifest(LocalFileState local) {
    if (local.size >= FastCdc.minSize || local.hash.length != 64) return null;
    return Manifest(
      size: local.size,
      hash: local.hash,
      chunks: [if (local.size > 0) ChunkRef(hash: local.hash, size: local.size)],
    );
  }

  Future<Manifest> _chunk(UploadItem item) async {
    final tracking = item.tracking;
    if (tracking == null) return FastCdc.manifestOfFile(item.source);
    final cancel = tracking.begin(LocalSyncPhase.preparing, item.local.size);
    return FastCdc.manifestOfFileTracked(item.source, onProgress: tracking.progress, cancel: cancel);
  }

  Future<List<UploadOutcome>> _send(List<_PreparedItem> prepared, String group, CancelToken? run) async {
    final firstPath = prepared.first.item.source.path;
    String? batchId;
    try {
      final created = await _api
          .createUploadBatch([for (final file in prepared) file.request])
          .unlessCancelled(run, firstPath);
      batchId = created.batchId;
      final body = _BatchBody(prepared, created, run);
      final done = await _api
          .streamUploadBatch(created.batchId, body.stream(), length: created.missingBytes)
          .unlessCancelled(run, firstPath);
      return _outcomesFrom(prepared, done.results);
    } on SyncCancelledException catch (cancelled) {
      if (batchId != null) await _keepOrAbort(batchId, group, cancelled.reason);
      return [
        for (final file in prepared)
          UploadOutcome.failed(file.item, SyncCancelledException(file.item.source.path, cancelled.reason)),
      ];
    } on Exception catch (error) {
      if (batchId != null) await _abortQuietly(batchId);
      return [for (final file in prepared) UploadOutcome.failed(file.item, error)];
    }
  }

  List<UploadOutcome> _outcomesFrom(List<_PreparedItem> prepared, List<UploadFileResult> results) {
    final byPath = {for (final result in results) result.path: result};
    return [for (final file in prepared) _outcomeOf(file, byPath[file.item.remotePath])];
  }

  UploadOutcome _outcomeOf(_PreparedItem file, UploadFileResult? result) {
    final changed = SyncCancelledException(file.item.source.path, CancelReason.changed);
    return switch (result) {
      UploadFileResult(:final entry?) => UploadOutcome.stored(
        file.item,
        UploadResult(entry: entry, manifest: file.manifest),
      ),
      UploadFileResult(error: PreconditionFailedException()) || null => UploadOutcome.failed(file.item, changed),
      UploadFileResult(:final error?) => UploadOutcome.failed(file.item, error),
      UploadFileResult() => UploadOutcome.failed(file.item, changed),
    };
  }

  Future<void> _keepOrAbort(String batchId, String group, CancelReason reason) async {
    if (reason == CancelReason.paused) {
      _pausedBatches.putIfAbsent(group, () => {}).add(batchId);
    } else {
      await _abortQuietly(batchId);
    }
  }

  Future<void> abortPausedBatches(String group) async {
    for (final batchId in _pausedBatches.remove(group) ?? const <String>{}) {
      await _abortQuietly(batchId);
    }
  }

  Future<void> _abortQuietly(String batchId) async {
    try {
      await _api.abortUploadBatch(batchId);
    } on Exception {
      return;
    }
  }
}

Future<void> _ensureUnchanged(UploadItem item, Manifest manifest) async {
  if (!await _isUnchanged(item, manifest)) throw SyncCancelledException(item.source.path, CancelReason.changed);
}

Future<bool> _isUnchanged(UploadItem item, Manifest manifest) async {
  final stat = await item.source.stat();
  return stat.type != FileSystemEntityType.notFound &&
      stat.size == manifest.size &&
      stat.modified.millisecondsSinceEpoch == item.local.mtime.millisecondsSinceEpoch;
}

class _PreparedItem {
  _PreparedItem(this.item, this.manifest);

  final UploadItem item;
  final Manifest manifest;

  UploadRequest get request => UploadRequest(
    path: item.remotePath,
    baseRev: item.baseRev,
    size: manifest.size,
    hash: manifest.hash,
    mtime: item.local.mtime.toUtc(),
    chunks: [for (final chunk in manifest.chunks) UploadChunkSpec(hash: chunk.hash, size: chunk.size)],
  );
}

class _BatchBody {
  _BatchBody(this._prepared, this._status, this._run);

  final List<_PreparedItem> _prepared;
  final UploadBatchStatus _status;
  final CancelToken? _run;

  late final Map<String, (_PreparedItem, ChunkRef)> _sources = _chunkSources();
  _ItemSender? _sender;

  Map<String, (_PreparedItem, ChunkRef)> _chunkSources() {
    final sources = <String, (_PreparedItem, ChunkRef)>{};
    for (final file in _prepared) {
      for (final chunk in file.manifest.chunks) {
        sources.putIfAbsent(chunk.hash, () => (file, chunk));
      }
    }
    return sources;
  }

  Map<_PreparedItem, int> _bytesToSendPerItem() {
    final totals = <_PreparedItem, int>{};
    for (final chunk in _status.missing) {
      final (file, _) = _sources[chunk.hash]!;
      totals.update(file, (total) => total + chunk.size, ifAbsent: () => chunk.size);
    }
    return totals;
  }

  Stream<List<int>> stream() async* {
    final totals = _bytesToSendPerItem();
    try {
      for (final missing in _status.missing) {
        _run?.throwIfCancelled(_prepared.first.item.source.path);
        final (file, chunk) = _sources[missing.hash]!;
        final sender = await _senderFor(file, totals[file]!);
        yield await sender.read(chunk);
      }
    } finally {
      await _sender?.close();
    }
  }

  Future<_ItemSender> _senderFor(_PreparedItem file, int total) async {
    final current = _sender;
    if (current != null && current.file == file) return current;
    await current?.close();
    return _sender = await _ItemSender.open(file, total);
  }
}

class _ItemSender {
  _ItemSender._(this.file, this._reader, this._cancel);

  static Future<_ItemSender> open(_PreparedItem file, int total) async {
    final cancel = file.item.tracking?.begin(LocalSyncPhase.uploading, total);
    if (!await _isUnchanged(file.item, file.manifest)) return _ItemSender._(file, null, cancel);
    try {
      return _ItemSender._(file, await file.item.source.open(), cancel);
    } on FileSystemException {
      return _ItemSender._(file, null, cancel);
    }
  }

  final _PreparedItem file;
  final RandomAccessFile? _reader;
  final CancelToken? _cancel;
  var _sent = 0;

  Future<Uint8List> read(ChunkRef chunk) async {
    final bytes = await _readOrZeros(chunk);
    _sent += chunk.size;
    file.item.tracking?.progress(_sent);
    return bytes;
  }

  Future<Uint8List> _readOrZeros(ChunkRef chunk) async {
    final reader = _reader;
    if (reader == null || (_cancel?.isCancelled ?? false)) return Uint8List(chunk.size);
    try {
      await reader.setPosition(chunk.offset);
      final bytes = await reader.read(chunk.size);
      return bytes.length == chunk.size ? bytes : (Uint8List(chunk.size)..setAll(0, bytes));
    } on FileSystemException {
      return Uint8List(chunk.size);
    }
  }

  Future<void> close() async => _reader?.close();
}
