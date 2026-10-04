import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/remote_state.dart";
import "package:nomad/models/sync/sync_action.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/util/relative_path.dart";

class Reconciler {
  const Reconciler({required this.rootId, required this.mode});

  final String rootId;
  final SyncMode mode;

  List<SyncAction> reconcile({
    required Map<String, LocalFileState> local,
    required Map<String, SyncEntry> synced,
    required Map<String, RemoteState> remote,
    Set<String> pending = const {},
  }) {
    final paths = {...local.keys, ...synced.keys, if (mode == SyncMode.sync) ...remote.keys}.difference(pending);
    final actions = [for (final path in paths) ?decide(path, local[path], synced[path], remote[path])];
    return _ordered(_withoutRedundantDeletes(actions, pending));
  }

  SyncAction? decide(String path, LocalFileState? local, SyncEntry? synced, RemoteState? remote) {
    if (mode == SyncMode.autoUpload) return _decideUploadOnly(path, local, synced);
    if (synced == null) return _decideUntracked(path, local, remote);
    if (synced.isPlaceholder && local == null) return _decidePlaceholder(path, synced, remote);
    return _decideTracked(path, local, synced, remote);
  }

  SyncAction? _decideUploadOnly(String path, LocalFileState? local, SyncEntry? synced) {
    if (local == null) return null;
    if (local.isDir) return synced == null ? SyncAction.createRemoteDir(path: path) : null;
    if (synced == null) return SyncAction.upload(path: path, local: local, baseRev: 0);
    if (_localChanged(local, synced)) return SyncAction.upload(path: path, local: local, baseRev: synced.syncedRev);
    return null;
  }

  SyncAction? _decideUntracked(String path, LocalFileState? local, RemoteState? remote) {
    final remoteEntry = _upsertedEntry(remote);
    if (local == null) return remoteEntry == null ? null : _fetch(path, remoteEntry);
    if (remoteEntry == null) return _push(path, local, baseRev: 0);
    if (_sameContent(local, remoteEntry)) return SyncAction.recordSynced(path: path, local: local, remote: remoteEntry);
    return _conflict(path, ConflictKind.bothCreated, local, remoteEntry);
  }

  SyncAction? _decidePlaceholder(String path, SyncEntry synced, RemoteState? remote) => switch (remote) {
    RemoteDeleted() => SyncAction.forget(path: path),
    RemoteUpserted(:final entry) when entry.rev != synced.syncedRev => SyncAction.updatePlaceholder(
      path: path,
      remote: entry,
    ),
    _ => null,
  };

  SyncAction? _decideTracked(String path, LocalFileState? local, SyncEntry synced, RemoteState? remote) {
    if (local == null) return _decideLocallyDeleted(path, synced, remote);
    if (remote is RemoteDeleted) return _decideRemotelyDeleted(path, local, synced);
    final remoteEntry = _upsertedEntry(remote);
    final localChanged = _localChanged(local, synced);
    final remoteChanged = remoteEntry != null && remoteEntry.rev != synced.syncedRev;
    if (remoteChanged && (_sameContent(local, remoteEntry) || local.isDir)) {
      return SyncAction.recordSynced(path: path, local: local, remote: remoteEntry);
    }
    if (localChanged && remoteChanged) return _conflict(path, ConflictKind.bothModified, local, remoteEntry);
    if (localChanged) return SyncAction.upload(path: path, local: local, baseRev: synced.syncedRev);
    if (remoteChanged) return SyncAction.download(path: path, remote: remoteEntry);
    return null;
  }

  SyncAction _decideLocallyDeleted(String path, SyncEntry synced, RemoteState? remote) {
    final remoteEntry = _upsertedEntry(remote);
    if (remote is RemoteDeleted) return SyncAction.forget(path: path);
    if (synced.isDir) return SyncAction.deleteRemote(path: path, baseRev: -1);
    if (remoteEntry != null && remoteEntry.rev != synced.syncedRev) {
      return _conflict(path, ConflictKind.localDeletedRemoteModified, null, remoteEntry);
    }
    return SyncAction.deleteRemote(path: path, baseRev: synced.syncedRev);
  }

  SyncAction _decideRemotelyDeleted(String path, LocalFileState local, SyncEntry synced) {
    if (_localChanged(local, synced)) return _conflict(path, ConflictKind.localModifiedRemoteDeleted, local, null);
    return SyncAction.deleteLocal(path: path);
  }

  SyncAction _fetch(String path, FileEntry remote) => remote.isDir
      ? SyncAction.createLocalDir(path: path, remote: remote)
      : SyncAction.download(path: path, remote: remote);

  SyncAction _push(String path, LocalFileState local, {required int baseRev}) => local.isDir
      ? SyncAction.createRemoteDir(path: path)
      : SyncAction.upload(path: path, local: local, baseRev: baseRev);

  SyncAction _conflict(String path, ConflictKind kind, LocalFileState? local, FileEntry? remote) => SyncAction.conflict(
    path: path,
    conflict: Conflict(syncRootId: rootId, relativePath: path, kind: kind, local: local, remote: remote),
  );

  FileEntry? _upsertedEntry(RemoteState? remote) => switch (remote) {
    RemoteUpserted(:final entry) => entry,
    _ => null,
  };

  bool _localChanged(LocalFileState local, SyncEntry synced) {
    if (local.isDir != synced.isDir) return true;
    return !local.isDir && local.hash != synced.syncedHash;
  }

  bool _sameContent(LocalFileState local, FileEntry remote) =>
      local.isDir == remote.isDir && (local.isDir || local.hash == remote.hash);

  List<SyncAction> _withoutRedundantDeletes(List<SyncAction> actions, Set<String> pending) {
    final keptPaths = [...actions.where((action) => !action.isDelete).map((action) => action.path), ...pending];
    final deletes = {
      for (final action in actions)
        if (action.isDelete && !_hasKeptDescendant(action.path, keptPaths)) action.path: action,
    };
    return actions
        .where((action) => !action.isDelete || deletes.containsKey(action.path) && !_coveredByAncestor(action, deletes))
        .toList();
  }

  bool _hasKeptDescendant(String path, List<String> keptPaths) =>
      keptPaths.any((kept) => RelativePath.isWithin(kept, path));

  bool _coveredByAncestor(SyncAction action, Map<String, SyncAction> deletes) {
    for (var parent = RelativePath.parent(action.path); parent != null; parent = RelativePath.parent(parent)) {
      if (deletes[parent]?.runtimeType == action.runtimeType) return true;
    }
    return false;
  }

  List<SyncAction> _ordered(List<SyncAction> actions) {
    int rank(SyncAction action) => action.isDirectoryCreation ? 0 : (action.isDelete ? 2 : 1);
    return [...actions]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final byDepth = a.isDelete ? b.depth.compareTo(a.depth) : a.depth.compareTo(b.depth);
      return byDepth != 0 ? byDepth : a.path.compareTo(b.path);
    });
  }
}
