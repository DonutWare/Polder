import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/sync/local_scanner.dart";
import "package:nomad/services/sync/sync_executor.dart";
import "package:nomad/services/sync/sync_paths.dart";
import "package:nomad/util/conflict_file_name.dart";
import "package:nomad/util/relative_path.dart";

class ConflictResolver {
  const ConflictResolver({
    required this._executor,
    required this._scanner,
    required this._deviceName,
    required this._clock,
  });

  final SyncExecutor _executor;
  final LocalScanner _scanner;
  final String _deviceName;
  final DateTime Function() _clock;

  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution) async {
    final local = await _scanner.stateOf(SyncPaths(root), conflict.relativePath);
    return switch (resolution) {
      ConflictResolution.keepMine => _keepMine(root, conflict, local),
      ConflictResolution.keepServer => _keepServer(root, conflict),
      ConflictResolution.keepBoth => _keepBoth(root, conflict, local),
    };
  }

  Future<void> _keepMine(SyncRoot root, Conflict conflict, LocalFileState? local) {
    final currentRev = conflict.remote?.rev ?? 0;
    if (local == null) return _executor.deleteRemote(root, conflict.relativePath, baseRev: currentRev);
    return _executor.upload(root, conflict.relativePath, local, baseRev: currentRev);
  }

  Future<void> _keepServer(SyncRoot root, Conflict conflict) {
    final remote = conflict.remote;
    if (remote == null) return _executor.deleteLocal(root, conflict.relativePath);
    return _executor.download(root, conflict.relativePath, remote);
  }

  Future<void> _keepBoth(SyncRoot root, Conflict conflict, LocalFileState? local) async {
    final remote = conflict.remote;
    if (local == null) return _keepServer(root, conflict);
    if (remote == null) return _keepMine(root, conflict, local);
    final copy = await _moveLocalToConflictCopy(root, conflict.relativePath);
    await _executor.upload(root, copy.relativePath, copy, baseRev: 0);
    await _executor.download(root, conflict.relativePath, remote);
  }

  Future<LocalFileState> _moveLocalToConflictCopy(SyncRoot root, String path) async {
    final paths = SyncPaths(root);
    final copyName = ConflictFileName.build(RelativePath.name(path), device: _deviceName, at: _clock());
    final copyPath = RelativePath.sibling(path, copyName);
    await paths.file(path).rename(paths.localPath(copyPath));
    return (await _scanner.stateOf(paths, copyPath))!;
  }
}
