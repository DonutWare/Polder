import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";

import "package:polder/models/api_error.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/manifest.dart";
import "package:polder/services/api/api_error_mapper.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/chunker.dart";
import "package:polder/services/sync/download_plan.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/services/sync/sync_ignore_rules.dart";

class DownloadResult {
  const DownloadResult({required this.hash, this.manifest});

  final String hash;
  final Manifest? manifest;
}

typedef BatchDownloadOutcome = ({DownloadResult? result, Exception? error});

class DeltaDownloader {
  DeltaDownloader(this._api, {this.maxAttempts = 3});

  final PolderApi _api;
  final int maxAttempts;
  final _random = Random();

  Future<DownloadResult> download({
    required FileEntry remote,
    required File target,
    Manifest? localManifest,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  }) async {
    final result = await _needsWholeFile(remote, target)
        ? await _downloadWhole(remote, target, cancel, onReceived)
        : await _downloadDeltaWithRetries(remote, target, localManifest, cancel, onReceived);
    await target.setLastModified(remote.mtime);
    return result;
  }

  static bool canBatch(FileEntry remote) => remote.hash.isNotEmpty && remote.size < FastCdc.minSize;

  Future<List<BatchDownloadOutcome>> downloadBatch(
    List<({FileEntry remote, File target})> files, {
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  }) async {
    final outcomes = <BatchDownloadOutcome>[];
    final firstPath = files.first.target.path;
    try {
      final stream = await _api
          .downloadBatch([for (final file in files) (path: file.remote.path, rev: file.remote.rev)])
          .unlessCancelled(cancel, firstPath);
      final records = _RecordReader(stream.unlessCancelled(cancel, firstPath));
      try {
        for (final file in files) {
          outcomes.add(await _receiveRecord(records, file.remote, file.target, cancel, onReceived));
        }
      } finally {
        await records.cancel();
      }
    } on Exception catch (error) {
      outcomes.addAll([for (final _ in files.skip(outcomes.length)) (result: null, error: error)]);
    }
    return outcomes;
  }

  Future<BatchDownloadOutcome> _receiveRecord(
    _RecordReader records,
    FileEntry remote,
    File target,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    final header = await records.nextHeader();
    if (header["error"] case final Map<String, dynamic> error) {
      return (result: null, error: _recordError(error, target));
    }
    final body = records.body(header["size"] as int);
    try {
      await target.parent.create(recursive: true);
      final hash = await _writeVerified(
        target,
        remote.hash,
        cancel,
        (writer) => writer.addStream(body, cancel, onReceived),
      );
      await target.setLastModified(remote.mtime);
      return (result: DownloadResult(hash: hash, manifest: _singleChunkManifest(remote, hash)), error: null);
    } on HashMismatchException catch (mismatch) {
      return (result: null, error: mismatch);
    }
  }

  Exception _recordError(Map<String, dynamic> error, File target) {
    final apiError = ApiError.fromJson(error);
    if (apiError.code == "precondition_failed") return SyncCancelledException(target.path, CancelReason.changed);
    return ApiErrorMapper.fromError(apiError);
  }

  Future<bool> _needsWholeFile(FileEntry remote, File target) async =>
      remote.hash.isNotEmpty && (remote.size < FastCdc.minSize || !await target.exists());

  Future<DownloadResult> _downloadWhole(
    FileEntry remote,
    File target,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    try {
      final hash = await _writeVerified(target, remote.hash, cancel, (writer) async {
        final content = await _api
            .openContent(remote.path, ifMatchRev: remote.rev)
            .unlessCancelled(cancel, target.path);
        await writer.addStream(content, cancel, onReceived);
      });
      return DownloadResult(hash: hash, manifest: _singleChunkManifest(remote, hash));
    } on PreconditionFailedException {
      throw SyncCancelledException(target.path, CancelReason.changed);
    }
  }

  Manifest? _singleChunkManifest(FileEntry remote, String hash) {
    if (remote.size >= FastCdc.minSize) return null;
    return Manifest(
      size: remote.size,
      hash: hash,
      chunks: [if (remote.size > 0) ChunkRef(hash: hash, size: remote.size)],
    );
  }

  Future<DownloadResult> _downloadDeltaWithRetries(
    FileEntry remote,
    File target,
    Manifest? localManifest,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _downloadDelta(remote.path, target, localManifest, cancel, onReceived);
      } on PreconditionFailedException {
        if (attempt >= maxAttempts) rethrow;
      }
    }
  }

  Future<DownloadResult> _downloadDelta(
    String remotePath,
    File target,
    Manifest? localManifest,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    final remote = await _api.manifest(remotePath);
    final local = await _localChunks(target, localManifest);
    final plan = DownloadPlan.build(remote, local);
    final reader = plan.any((segment) => segment is LocalSegment) ? await target.open() : null;
    try {
      final hash = await _writeVerified(target, remote.hash, cancel, (writer) async {
        for (final segment in plan) {
          cancel?.throwIfCancelled(target.path);
          switch (segment) {
            case LocalSegment():
              await reader!.setPosition(segment.offset);
              writer.add(await reader.read(segment.size));
            case RemoteSegment():
              final range = ByteRange(segment.offset, segment.size);
              final content = await _api
                  .openContent(remotePath, range: range, ifMatchRev: remote.rev)
                  .unlessCancelled(cancel, target.path);
              await writer.addStream(content, cancel, onReceived);
          }
        }
      });
      return DownloadResult(hash: hash, manifest: remote);
    } finally {
      await reader?.close();
    }
  }

  Future<Map<String, ChunkRef>> _localChunks(File target, Manifest? known) async {
    if (!await target.exists()) return const {};
    return (known ?? await FastCdc.manifestOfFile(target)).chunksByHash;
  }

  Future<String> _writeVerified(
    File target,
    String expectedHash,
    CancelToken? cancel,
    Future<void> Function(_HashingWriter writer) write,
  ) async {
    final temp = _tempFileFor(target);
    try {
      await temp.parent.create(recursive: true);
      final writer = _HashingWriter(temp.openWrite(), target.path);
      try {
        await write(writer);
      } finally {
        await writer.close();
      }
      cancel?.throwIfCancelled(target.path);
      final actual = writer.hash;
      if (actual != expectedHash) throw HashMismatchException(expected: expectedHash, actual: actual);
      await temp.rename(target.path);
      return actual;
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }

  File _tempFileFor(File target) {
    final name = target.uri.pathSegments.last;
    return File(
      "${target.parent.path}${Platform.pathSeparator}${SyncIgnoreRules.tempPrefix}-${_random.nextInt(1 << 32)}-$name",
    );
  }
}

class _HashingWriter {
  _HashingWriter(this._sink, this._path);

  final IOSink _sink;
  final String _path;
  final _digest = DigestCollector();
  late final _hasher = sha256.startChunkedConversion(_digest);

  String get hash => _digest.hex;

  void add(List<int> bytes) {
    _sink.add(bytes);
    _hasher.add(bytes);
  }

  Future<void> addStream(Stream<List<int>> content, CancelToken? cancel, void Function(int bytes)? onReceived) async {
    await _sink.addStream(
      content.unlessCancelled(cancel, _path).map((chunk) {
        _hasher.add(chunk);
        onReceived?.call(chunk.length);
        return chunk;
      }),
    );
  }

  Future<void> close() async {
    _hasher.close();
    await _sink.close();
  }
}

class _RecordReader {
  _RecordReader(Stream<Uint8List> stream) : _chunks = StreamIterator(stream);

  final StreamIterator<Uint8List> _chunks;
  Uint8List _pending = Uint8List(0);

  Future<Map<String, dynamic>> nextHeader() async {
    final line = BytesBuilder(copy: false);
    while (true) {
      final newline = _pending.indexOf(10);
      if (newline >= 0) {
        line.add(Uint8List.sublistView(_pending, 0, newline));
        _pending = Uint8List.sublistView(_pending, newline + 1);
        return jsonDecode(utf8.decode(line.takeBytes())) as Map<String, dynamic>;
      }
      line.add(_pending);
      await _refill();
    }
  }

  Stream<Uint8List> body(int size) async* {
    var remaining = size;
    while (remaining > 0) {
      if (_pending.isEmpty) await _refill();
      final taken = min(remaining, _pending.length);
      yield Uint8List.sublistView(_pending, 0, taken);
      _pending = Uint8List.sublistView(_pending, taken);
      remaining -= taken;
    }
  }

  Future<void> cancel() => _chunks.cancel();

  Future<void> _refill() async {
    if (!await _chunks.moveNext()) throw const FormatException("the download stream ended early");
    _pending = _chunks.current;
  }
}
