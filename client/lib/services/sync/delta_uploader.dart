import "dart:io";
import "dart:typed_data";

import "package:polder/models/file_entry.dart";
import "package:polder/models/manifest.dart";
import "package:polder/models/upload_session.dart";
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

class DeltaUploader {
  DeltaUploader(this._api);

  final PolderApi _api;

  final Map<String, ({String uploadId, String hash})> _paused = {};

  Future<UploadResult> upload({
    required File source,
    required String remotePath,
    required int baseRev,
    required DateTime mtime,
    Manifest? manifest,
    UploadTracking? tracking,
  }) async {
    final prepared = manifest ?? await _manifestOf(source, tracking);
    await _ensureUnchanged(source, prepared, mtime, tracking);
    final entry = prepared.size < FastCdc.minSize
        ? await _putWhole(source, remotePath, prepared, baseRev, mtime, tracking)
        : await _putChunked(source, remotePath, prepared, baseRev, mtime, tracking);
    return UploadResult(entry: entry, manifest: prepared);
  }

  Future<Manifest> _manifestOf(File source, UploadTracking? tracking) async {
    if (tracking == null) return FastCdc.manifestOfFile(source);
    final cancel = tracking.begin(LocalSyncPhase.preparing, await source.length());
    return FastCdc.manifestOfFileTracked(source, onProgress: tracking.progress, cancel: cancel);
  }

  Future<void> _ensureUnchanged(File source, Manifest manifest, DateTime mtime, UploadTracking? tracking) async {
    if (tracking == null) return;
    final stat = await source.stat();
    if (stat.type == FileSystemEntityType.notFound ||
        stat.size != manifest.size ||
        stat.modified.millisecondsSinceEpoch != mtime.millisecondsSinceEpoch) {
      throw SyncCancelledException(source.path, CancelReason.changed);
    }
  }

  Future<FileEntry> _putWhole(
    File source,
    String remotePath,
    Manifest manifest,
    int baseRev,
    DateTime mtime,
    UploadTracking? tracking,
  ) {
    final cancel = tracking?.begin(LocalSyncPhase.uploading, manifest.size)?..throwIfCancelled(source.path);
    return _api
        .putContent(
          remotePath,
          source.openRead().unlessCancelled(cancel, source.path),
          length: manifest.size,
          baseRev: baseRev,
          mtime: mtime,
          onProgress: tracking == null ? null : (sent, _) => tracking.progress(sent),
        )
        .unlessCancelled(cancel, source.path);
  }

  Future<FileEntry> _putChunked(
    File source,
    String remotePath,
    Manifest manifest,
    int baseRev,
    DateTime mtime,
    UploadTracking? tracking,
  ) async {
    final session =
        await _resumePaused(remotePath, manifest) ??
        await _api.createUpload(_requestFor(remotePath, manifest, baseRev, mtime));
    try {
      final chunks = manifest.chunksByHash;
      final total = session.missing.fold(0, (sum, hash) => sum + chunks[hash]!.size);
      final cancel = tracking?.begin(LocalSyncPhase.uploading, total);
      await _sendMissingChunks(source, session, chunks, cancel, tracking);
      cancel?.throwIfCancelled(source.path);
      await _ensureUnchanged(source, manifest, mtime, tracking);
      return await _api.commitUpload(session.uploadId);
    } on SyncCancelledException catch (error) {
      if (error.reason == CancelReason.paused) {
        _paused[remotePath] = (uploadId: session.uploadId, hash: manifest.hash);
      } else {
        await _abortQuietly(session.uploadId);
      }
      rethrow;
    } catch (_) {
      await _abortQuietly(session.uploadId);
      rethrow;
    }
  }

  Future<UploadSession?> _resumePaused(String remotePath, Manifest manifest) async {
    final paused = _paused.remove(remotePath);
    if (paused == null) return null;
    if (paused.hash != manifest.hash) {
      await _abortQuietly(paused.uploadId);
      return null;
    }
    try {
      return await _api.uploadStatus(paused.uploadId);
    } on NotFoundException {
      return null;
    }
  }

  UploadRequest _requestFor(String remotePath, Manifest manifest, int baseRev, DateTime mtime) => UploadRequest(
    path: remotePath,
    baseRev: baseRev,
    size: manifest.size,
    hash: manifest.hash,
    mtime: mtime.toUtc(),
    chunks: [for (final chunk in manifest.chunks) UploadChunkSpec(hash: chunk.hash, size: chunk.size)],
  );

  Future<void> _sendMissingChunks(
    File source,
    UploadSession session,
    Map<String, ChunkRef> chunks,
    CancelToken? cancel,
    UploadTracking? tracking,
  ) async {
    final reader = await source.open();
    var sent = 0;
    try {
      for (final hash in session.missing) {
        cancel?.throwIfCancelled(source.path);
        final chunk = chunks[hash]!;
        await _api.putChunk(session.uploadId, hash, await _read(reader, chunk)).unlessCancelled(cancel, source.path);
        sent += chunk.size;
        tracking?.progress(sent);
      }
    } finally {
      await reader.close();
    }
  }

  Future<Uint8List> _read(RandomAccessFile reader, ChunkRef chunk) async {
    await reader.setPosition(chunk.offset);
    return reader.read(chunk.size);
  }

  Future<void> _abortQuietly(String uploadId) async {
    try {
      await _api.abortUpload(uploadId);
    } on Exception {
      return;
    }
  }
}
