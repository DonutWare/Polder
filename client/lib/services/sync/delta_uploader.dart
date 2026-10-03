import "dart:io";
import "dart:typed_data";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/manifest.dart";
import "package:nomad/models/upload_session.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/chunker.dart";

class UploadResult {
  const UploadResult({required this.entry, required this.manifest});

  final FileEntry entry;
  final Manifest manifest;
}

class DeltaUploader {
  DeltaUploader(this._api);

  final NomadApi _api;

  Future<UploadResult> upload({
    required File source,
    required String remotePath,
    required int baseRev,
    required DateTime mtime,
  }) async {
    final manifest = await FastCdc.manifestOfFile(source);
    final entry = manifest.size < FastCdc.minSize
        ? await _putWhole(source, remotePath, manifest, baseRev, mtime)
        : await _putChunked(source, remotePath, manifest, baseRev, mtime);
    return UploadResult(entry: entry, manifest: manifest);
  }

  Future<FileEntry> _putWhole(File source, String remotePath, Manifest manifest, int baseRev, DateTime mtime) =>
      _api.putContent(remotePath, source.openRead(), length: manifest.size, baseRev: baseRev, mtime: mtime);

  Future<FileEntry> _putChunked(File source, String remotePath, Manifest manifest, int baseRev, DateTime mtime) async {
    final session = await _api.createUpload(_requestFor(remotePath, manifest, baseRev, mtime));
    try {
      await _sendMissingChunks(source, session, manifest.chunksByHash);
      return await _api.commitUpload(session.uploadId);
    } catch (_) {
      await _abortQuietly(session.uploadId);
      rethrow;
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

  Future<void> _sendMissingChunks(File source, UploadSession session, Map<String, ChunkRef> chunks) async {
    final reader = await source.open();
    try {
      for (final hash in session.missing) {
        final chunk = chunks[hash]!;
        await _api.putChunk(session.uploadId, hash, await _read(reader, chunk));
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
