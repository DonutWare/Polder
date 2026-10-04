import "dart:io";
import "dart:isolate";

import "package:crypto/crypto.dart";

import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_exceptions.dart";
import "package:nomad/services/sync/sync_ignore_rules.dart";
import "package:nomad/services/sync/sync_paths.dart";

class LocalScan {
  final Map<String, LocalFileState> known = {};
  final Set<String> dirty = {};
  final Set<String> deferred = {};
}

typedef FileHasher = Future<String> Function(File file, String relativePath, int size);

class LocalScanner {
  const LocalScanner({this._hasher});

  final FileHasher? _hasher;

  Future<Map<String, LocalFileState>> scan(
    SyncPaths paths,
    Map<String, SyncEntry> synced, {
    Set<String>? deferred,
  }) async {
    final root = Directory(paths.root.localPath);
    if (!await root.exists()) throw LocalRootMissingException(root.path);
    final result = <String, LocalFileState>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      final relativePath = paths.relativePath(entity.path);
      if (entity is Link || SyncIgnoreRules.isIgnored(relativePath)) continue;
      if (deferred == null) {
        result[relativePath] = (await _stateOf(entity, relativePath, synced[relativePath]))!;
        continue;
      }
      try {
        final state = await _stateOf(entity, relativePath, synced[relativePath], requireSettled: true);
        if (state == null) {
          deferred.add(relativePath);
        } else {
          result[relativePath] = state;
        }
      } on SyncCancelledException {
        deferred.add(relativePath);
      } on FileSystemException {
        if (await entity.exists()) rethrow;
        deferred.add(relativePath);
      }
    }
    return result;
  }

  Future<LocalScan> quickScan(SyncPaths paths, Map<String, SyncEntry> synced) async {
    final root = Directory(paths.root.localPath);
    if (!await root.exists()) throw LocalRootMissingException(root.path);
    final scan = LocalScan();
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      final relativePath = paths.relativePath(entity.path);
      if (entity is Link || SyncIgnoreRules.isIgnored(relativePath)) continue;
      final stat = await entity.stat();
      if (stat.type == FileSystemEntityType.notFound) {
        scan.deferred.add(relativePath);
        continue;
      }
      final mtime = stat.modified.toUtc();
      if (entity is Directory) {
        scan.known[relativePath] = LocalFileState(relativePath: relativePath, isDir: true, mtime: mtime);
        continue;
      }
      final reusable = _reusableHash(synced[relativePath], stat.size, mtime);
      if (reusable == null) {
        scan.dirty.add(relativePath);
      } else {
        scan.known[relativePath] = LocalFileState(
          relativePath: relativePath,
          size: stat.size,
          mtime: mtime,
          hash: reusable,
        );
      }
    }
    return scan;
  }

  Future<LocalFileState?> settledState(SyncPaths paths, String relativePath, {SyncEntry? synced}) async {
    final file = paths.file(relativePath);
    try {
      return await _stateOf(file, relativePath, synced, requireSettled: true);
    } on SyncCancelledException {
      return null;
    } on FileSystemException {
      if (await file.exists()) rethrow;
      return null;
    }
  }

  Future<LocalFileState?> stateOf(SyncPaths paths, String relativePath, {SyncEntry? synced}) async {
    final entity = switch (await FileSystemEntity.type(paths.localPath(relativePath), followLinks: false)) {
      FileSystemEntityType.file => paths.file(relativePath),
      FileSystemEntityType.directory => paths.directory(relativePath),
      _ => null,
    };
    return entity == null ? null : (await _stateOf(entity, relativePath, synced))!;
  }

  Future<LocalFileState?> _stateOf(
    FileSystemEntity entity,
    String relativePath,
    SyncEntry? synced, {
    bool requireSettled = false,
  }) async {
    final stat = await entity.stat();
    if (stat.type == FileSystemEntityType.notFound) throw PathNotFoundException(entity.path, const OSError());
    final mtime = stat.modified.toUtc();
    if (entity is Directory) return LocalFileState(relativePath: relativePath, isDir: true, mtime: mtime);
    final reusable = _reusableHash(synced, stat.size, mtime);
    if (reusable != null) {
      return LocalFileState(relativePath: relativePath, size: stat.size, mtime: mtime, hash: reusable);
    }
    final file = entity as File;
    final hash = await (_hasher?.call(file, relativePath, stat.size) ?? hashFile(file));
    if (requireSettled) {
      final after = await file.stat();
      if (after.size != stat.size || after.modified.millisecondsSinceEpoch != stat.modified.millisecondsSinceEpoch) {
        return null;
      }
    }
    return LocalFileState(relativePath: relativePath, size: stat.size, mtime: mtime, hash: hash);
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
