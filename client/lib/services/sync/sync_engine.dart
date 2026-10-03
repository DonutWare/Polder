import "dart:io";

import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/remote_state.dart";
import "package:nomad/models/sync/sync_action.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/conflict_resolver.dart";
import "package:nomad/services/sync/local_scanner.dart";
import "package:nomad/services/sync/reconciler.dart";
import "package:nomad/services/sync/remote_change_set.dart";
import "package:nomad/services/sync/sync_exceptions.dart";
import "package:nomad/services/sync/sync_executor.dart";
import "package:nomad/services/sync/sync_paths.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";
import "package:nomad/util/remote_path.dart";

typedef RemoteSnapshot = ({Map<String, RemoteState> states, List<RemoteMove> moves, int cursor});

typedef _Location = ({SyncRoot root, String path});

class SyncEngine implements SyncService {
  SyncEngine({
    required NomadApi api,
    required SyncStateStore store,
    required String deviceName,
    LocalScanner scanner = const LocalScanner(),
    SyncExecutor? executor,
    DateTime Function() clock = DateTime.now,
  }) : _api = api,
       _store = store,
       _scanner = scanner,
       _executor = executor ?? SyncExecutor(api: api, store: store) {
    _resolver = ConflictResolver(executor: _executor, scanner: scanner, deviceName: deviceName, clock: clock);
  }

  final NomadApi _api;
  final SyncStateStore _store;
  final LocalScanner _scanner;
  final SyncExecutor _executor;
  late final ConflictResolver _resolver;

  @override
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}}) async {
    if (!await Directory(root.localPath).exists()) throw LocalRootMissingException(root.localPath);
    final remote = root.mode == SyncMode.sync ? await _fetchRemote(root, await _store.entries(root.id)) : null;
    var report = remote == null ? const SyncRunReport() : await _applyMoves(root, remote.moves, pausedPaths);
    final synced = await _store.entries(root.id);
    final local = await _scanner.scan(SyncPaths(root), synced);
    final actions = Reconciler(
      rootId: root.id,
      mode: root.mode,
    ).reconcile(local: local, synced: synced, remote: remote?.states ?? const {});
    for (final action in actions.where((action) => !pausedPaths.contains(action.path))) {
      report += await _executeSafely(root, action, synced);
    }
    if (remote != null && !report.hasFailures) await _store.saveCursor(root.id, remote.cursor);
    return report;
  }

  @override
  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution) =>
      _resolver.resolve(root, conflict, resolution);

  Future<RemoteSnapshot> _fetchRemote(SyncRoot root, Map<String, SyncEntry> synced) async {
    final changes = RemoteChangeSet(remoteRoot: root.remotePath, synced: synced);
    var cursor = await _store.cursor(root.id);
    var hasMore = true;
    while (hasMore) {
      final page = await _api.changes(cursor: cursor);
      changes.applyAll(page.changes);
      cursor = page.cursor;
      hasMore = page.hasMore;
    }
    return (states: changes.states, moves: changes.moves, cursor: cursor);
  }

  /// Applies server-side moves that touch [root] by moving the local file, instead of deleting it and
  /// downloading it again. The other side may be a different sync root; whichever root syncs first moves it.
  Future<SyncRunReport> _applyMoves(SyncRoot root, List<RemoteMove> moves, Set<String> pausedPaths) async {
    if (moves.isEmpty) return const SyncRunReport();
    final roots = await _moveCandidateRoots(root);
    final entries = <String, Map<String, SyncEntry>>{};
    Future<Map<String, SyncEntry>> entriesOf(SyncRoot of) async => entries[of.id] ??= await _store.entries(of.id);
    var report = const SyncRunReport();
    for (final move in moves) {
      final source = _locate(roots, move.from);
      final target = _locate(roots, move.to);
      if (source == null || target == null) continue;
      if (source.root.id != root.id && target.root.id != root.id) continue;
      if (_isPaused(root, source, pausedPaths) || _isPaused(root, target, pausedPaths)) continue;
      final previous = (await entriesOf(source.root))[source.path];
      if (previous == null || !await _canMove(source, previous, target, await entriesOf(target.root))) continue;
      try {
        await _executor.relocate(
          fromRoot: source.root,
          previous: previous,
          toRoot: target.root,
          toPath: target.path,
          remote: move.entry,
        );
      } on FileSystemException {
        // E.g. the roots are on different volumes; the regular download and delete take over.
        continue;
      }
      entries[source.root.id]!.remove(source.path);
      entries[target.root.id]![target.path] = previous.copyWith(syncRootId: target.root.id, relativePath: target.path);
      report += const SyncRunReport(moved: 1);
    }
    return report;
  }

  Future<List<SyncRoot>> _moveCandidateRoots(SyncRoot root) async {
    final others = (await _store.roots()).where(
      (other) =>
          other.id != root.id && other.accountId == root.accountId && other.enabled && other.mode == SyncMode.sync,
    );
    return [
      root,
      for (final other in others)
        if (await Directory(other.localPath).exists()) other,
    ];
  }

  _Location? _locate(List<SyncRoot> roots, String remotePath) {
    _Location? best;
    for (final candidate in roots) {
      final path = RemotePath.relativeTo(remotePath, candidate.remotePath);
      if (path != null && (best == null || candidate.remotePath.length > best.root.remotePath.length)) {
        best = (root: candidate, path: path);
      }
    }
    return best;
  }

  bool _isPaused(SyncRoot root, _Location location, Set<String> pausedPaths) =>
      location.root.id == root.id && pausedPaths.contains(location.path);

  Future<bool> _canMove(
    _Location source,
    SyncEntry previous,
    _Location target,
    Map<String, SyncEntry> targetEntries,
  ) async {
    if (previous.isDir || previous.isPlaceholder || targetEntries.containsKey(target.path)) return false;
    final targetPaths = SyncPaths(target.root);
    if (await FileSystemEntity.type(targetPaths.localPath(target.path), followLinks: false) !=
        FileSystemEntityType.notFound) {
      return false;
    }
    final local = await _scanner.stateOf(SyncPaths(source.root), source.path, synced: previous);
    return local != null && !local.isDir && local.hash == previous.syncedHash;
  }

  Future<SyncRunReport> _executeSafely(SyncRoot root, SyncAction action, Map<String, SyncEntry> synced) async {
    try {
      return await _execute(root, action, synced);
    } on ConflictException catch (error) {
      return SyncRunReport.conflict(_conflictFromRejection(root, action, error));
    } on ApiException catch (error) {
      return SyncRunReport.failure("${action.path}: $error");
    } on FileSystemException catch (error) {
      return SyncRunReport.failure("${action.path}: ${error.message}");
    } on HashMismatchException catch (error) {
      return SyncRunReport.failure("${action.path}: $error");
    }
  }

  Future<SyncRunReport> _execute(SyncRoot root, SyncAction action, Map<String, SyncEntry> synced) async {
    switch (action) {
      case CreateRemoteDirAction(:final path):
        await _executor.createRemoteDir(root, path);
        return const SyncRunReport(uploaded: 1);
      case CreateLocalDirAction(:final path, :final remote):
        await _executor.createLocalDir(root, path, remote);
        return const SyncRunReport(downloaded: 1);
      case UploadAction(:final path, :final local, :final baseRev):
        await _executor.upload(root, path, local, baseRev: baseRev);
        return const SyncRunReport(uploaded: 1);
      case DownloadAction(:final path, :final remote):
        await _executor.download(root, path, remote, previous: synced[path]);
        return const SyncRunReport(downloaded: 1);
      case DeleteLocalAction(:final path):
        await _executor.deleteLocal(root, path);
        return const SyncRunReport(deleted: 1);
      case DeleteRemoteAction(:final path, :final baseRev):
        await _executor.deleteRemote(root, path, baseRev: baseRev);
        return const SyncRunReport(deleted: 1);
      case RecordSyncedAction(:final path, :final local, :final remote):
        await _executor.recordSynced(root, path, local, remote);
      case UpdatePlaceholderAction(:final path, :final remote):
        await _executor.savePlaceholder(root, path, remote);
      case ForgetAction(:final path):
        await _executor.forget(root, path);
      case ConflictAction(:final conflict):
        return SyncRunReport.conflict(conflict);
    }
    return const SyncRunReport();
  }

  Conflict _conflictFromRejection(SyncRoot root, SyncAction action, ConflictException error) {
    final local = action is UploadAction ? action.local : null;
    final kind = switch ((local, error.current)) {
      (null, _) => ConflictKind.localDeletedRemoteModified,
      (_, null) => ConflictKind.localModifiedRemoteDeleted,
      _ => ConflictKind.bothModified,
    };
    return Conflict(syncRootId: root.id, relativePath: action.path, kind: kind, local: local, remote: error.current);
  }
}
