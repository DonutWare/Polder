import "dart:io";
import "dart:math";

import "package:polder/models/manifest.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/chunker.dart";
import "package:polder/services/sync/download_plan.dart";
import "package:polder/services/sync/local_scanner.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/services/sync/sync_ignore_rules.dart";

class DeltaDownloader {
  DeltaDownloader(this._api, {this.maxAttempts = 3});

  final PolderApi _api;
  final int maxAttempts;
  final _random = Random();

  Future<Manifest> download({
    required String remotePath,
    required File target,
    Manifest? localManifest,
    DateTime? mtime,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  }) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _downloadOnce(remotePath, target, localManifest, mtime, cancel, onReceived);
      } on PreconditionFailedException {
        if (attempt >= maxAttempts) rethrow;
      }
    }
  }

  Future<Manifest> _downloadOnce(
    String remotePath,
    File target,
    Manifest? localManifest,
    DateTime? mtime,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    final remote = await _api.manifest(remotePath);
    final local = await _localChunks(target, localManifest);
    final temp = _tempFileFor(target);
    try {
      await _assemble(remotePath, remote, DownloadPlan.build(remote, local), target, temp, cancel, onReceived);
      cancel?.throwIfCancelled(target.path);
      await _verify(temp, remote.hash);
      await temp.rename(target.path);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
    if (mtime != null) await target.setLastModified(mtime);
    return remote;
  }

  Future<Map<String, ChunkRef>> _localChunks(File target, Manifest? known) async {
    if (!await target.exists()) return const {};
    return (known ?? await FastCdc.manifestOfFile(target)).chunksByHash;
  }

  File _tempFileFor(File target) {
    final name = target.uri.pathSegments.last;
    return File(
      "${target.parent.path}${Platform.pathSeparator}${SyncIgnoreRules.tempPrefix}-${_random.nextInt(1 << 32)}-$name",
    );
  }

  Future<void> _assemble(
    String remotePath,
    Manifest remote,
    List<DownloadSegment> plan,
    File source,
    File temp,
    CancelToken? cancel,
    void Function(int bytes)? onReceived,
  ) async {
    await temp.parent.create(recursive: true);
    final sink = temp.openWrite();
    final reader = plan.any((segment) => segment is LocalSegment) ? await source.open() : null;
    try {
      for (final segment in plan) {
        cancel?.throwIfCancelled(source.path);
        switch (segment) {
          case LocalSegment():
            await reader!.setPosition(segment.offset);
            sink.add(await reader.read(segment.size));
          case RemoteSegment():
            final content = await _api
                .openContent(remotePath, range: ByteRange(segment.offset, segment.size), ifMatchRev: remote.rev)
                .unlessCancelled(cancel, source.path);
            await sink.addStream(
              content.unlessCancelled(cancel, source.path).map((chunk) {
                onReceived?.call(chunk.length);
                return chunk;
              }),
            );
        }
      }
    } finally {
      await sink.close();
      await reader?.close();
    }
  }

  Future<void> _verify(File file, String expectedHash) async {
    final actual = await LocalScanner.hashFile(file);
    if (actual != expectedHash) throw HashMismatchException(expected: expectedHash, actual: actual);
  }
}
