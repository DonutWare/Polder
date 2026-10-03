import "dart:io";
import "dart:isolate";

import "package:crypto/crypto.dart";

import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/services/sync/sync_exceptions.dart";
import "package:nomad/services/sync/sync_ignore_rules.dart";
import "package:nomad/services/sync/sync_paths.dart";

class LocalScanner {
  const LocalScanner();

  Future<Map<String, LocalFileState>> scan(SyncPaths paths, Map<String, SyncEntry> synced) async {
    final root = Directory(paths.root.localPath);
    if (!await root.exists()) throw LocalRootMissingException(root.path);
    final result = <String, LocalFileState>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      final relativePath = paths.relativePath(entity.path);
      if (entity is Link || SyncIgnoreRules.isIgnored(relativePath)) continue;
      result[relativePath] = await _stateOf(entity, relativePath, synced[relativePath]);
    }
    return result;
  }

  Future<LocalFileState?> stateOf(SyncPaths paths, String relativePath, {SyncEntry? synced}) async {
    final entity = switch (await FileSystemEntity.type(paths.localPath(relativePath), followLinks: false)) {
      FileSystemEntityType.file => paths.file(relativePath),
      FileSystemEntityType.directory => paths.directory(relativePath),
      _ => null,
    };
    return entity == null ? null : _stateOf(entity, relativePath, synced);
  }

  Future<LocalFileState> _stateOf(FileSystemEntity entity, String relativePath, SyncEntry? synced) async {
    final stat = await entity.stat();
    final mtime = stat.modified.toUtc();
    if (entity is Directory) return LocalFileState(relativePath: relativePath, isDir: true, mtime: mtime);
    return LocalFileState(
      relativePath: relativePath,
      size: stat.size,
      mtime: mtime,
      hash: _reusableHash(synced, stat.size, mtime) ?? await hashFile(entity as File),
    );
  }

  String? _reusableHash(SyncEntry? synced, int size, DateTime mtime) {
    if (synced == null || synced.localSize != size) return null;
    if (synced.localMtime?.millisecondsSinceEpoch != mtime.millisecondsSinceEpoch) return null;
    return synced.localHash;
  }

  /// Files up to this size are hashed in place; spawning an isolate would cost more than it saves.
  static const backgroundHashThreshold = 1024 * 1024;

  /// Large files are hashed on a background isolate so hashing never stalls the UI.
  static Future<String> hashFile(File file) async {
    if (await file.length() <= backgroundHashThreshold) return _hashStream(file);
    final path = file.path;
    return Isolate.run(() => _hashStream(File(path)), debugName: "hash ${file.uri.pathSegments.last}");
  }

  static Future<String> _hashStream(File file) async => (await sha256.bind(file.openRead()).first).toString();
}
