import "dart:io";

import "package:nomad/models/manifest.dart";
import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/remote_state.dart";
import "package:nomad/models/sync/sync_action.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/chunker.dart";
import "package:nomad/services/sync/conflict_resolver.dart";
import "package:nomad/services/sync/local_scanner.dart";
import "package:nomad/services/sync/reconciler.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/remote_change_set.dart";
import "package:nomad/services/sync/sync_exceptions.dart";
import "package:nomad/services/sync/sync_executor.dart";
import "package:nomad/services/sync/sync_paths.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/work_queue.dart";
import "package:nomad/services/sync/sync_state_store.dart";
import "package:nomad/util/remote_path.dart";

typedef RemoteSnapshot = ({Map<String, RemoteState> states, List<RemoteMove> moves, int cursor});

typedef _Location = ({SyncRoot root, String path});

class SyncEngine implements SyncService {
  SyncEngine({
    required NomadApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
    LocalScanner scanner = const LocalScanner(),
    SyncExecutor? executor,
    DateTime Function() clock = DateTime.now,
  }) : _api = api,
       _store = store,
       _activity = activity,
       _scanner = scanner,
       _clock = clock,
       _executor = executor ?? SyncExecutor(api: api, store: store, activity: activity) {
    _resolver = ConflictResolver(executor: _executor, scanner: scanner, deviceName: deviceName, clock: clock);
  }

  final NomadApi _api;
  final SyncStateStore _store;
  final SyncActivity? _activity;
  final LocalScanner _scanner;
  final SyncExecutor _executor;
  final DateTime Function() _clock;
  late final ConflictResolver _resolver;

  static const hashWorkers = 2;
  static const uploadWorkers = 2;

  @override
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}}) async {
    if (!await Directory(root.localPath).exists()) throw LocalRootMissingException(root.localPath);
    final startedAt = _clock();
    final run = _activity?.startRun(root.id) ?? CancelToken();
    try {
      return await _run(root, pausedPaths, run);
    } finally {
      _activity?.endRun(root.id, run);
      _activity?.settle(root.id, startedAt);
    }
  }

  Future<SyncRunReport> _run(SyncRoot root, Set<String> pausedPaths, CancelToken run) async {
    final remote = root.mode == SyncMode.sync ? await _fetchRemote(root, await _store.entries(root.id)) : null;
    var report = remote == null ? const SyncRunReport() : await _applyMoves(root, remote.moves, pausedPaths);
    final synced = await _store.entries(root.id);
    final remoteStates = remote?.states ?? const <String, RemoteState>{};
    final paths = SyncPaths(root);
    final reconciler = Reconciler(rootId: root.id, mode: root.mode);
    final prepared = <String, Manifest>{};
    final scanner = _activity == null ? _scanner : LocalScanner(hasher: _preparingHasher(root, prepared));
    final scan = await scanner.quickScan(paths, synced);
    final deferred = {...scan.deferred};
    bool skipped(String path) => pausedPaths.contains(path) || deferred.contains(path);
    final dirty = [...scan.dirty.where((path) => !skipped(path))]..sort();
    if (!run.isCancelled) _activity?.enqueue(root, dirty);

    Future<void> execute(SyncAction action) async {
      if (run.isCancelled) {
        deferred.add(action.path);
        return;
      }
      final outcome = await _executeSafely(root, action, synced, prepared, run);
      report += outcome;
    }

    final firstPass = reconciler.reconcile(
      local: scan.known,
      synced: synced,
      remote: remoteStates,
      pending: {...scan.dirty, ...deferred},
    );
    for (final action in firstPass.where((action) => !action.isDelete && !skipped(action.path))) {
      await execute(action);
    }

    final hashed = <String, LocalFileState>{};
    final uploads = AsyncQueue<SyncAction>(capacity: uploadWorkers * 2);
    final hashing = runPool(dirty, hashWorkers, (path) async {
      if (run.isCancelled) {
        deferred.add(path);
        return;
      }
      final state = await scanner.settledState(paths, path, synced: synced[path]);
      if (state == null) {
        deferred.add(path);
        return;
      }
      hashed[path] = state;
      final action = reconciler.decide(path, state, synced[path], remoteStates[path]);
      if (action != null) await uploads.add(action);
    }).whenComplete(uploads.close);
    await Future.wait([hashing, uploads.drain(uploadWorkers, execute)]);

    if (!run.isCancelled) {
      final lastPass = reconciler.reconcile(
        local: {...scan.known, ...hashed},
        synced: synced,
        remote: remoteStates,
        pending: {...deferred, ...pausedPaths},
      );
      for (final action in lastPass.where((action) => action.isDelete)) {
        await execute(action);
      }
    }
    report += SyncRunReport(deferred: deferred.length);
    // Deferred files may hide remote changes to them, so their part of the feed is read again next time.
    if (remote != null && !report.hasFailures && report.deferred == 0 && !run.isCancelled) {
      await _store.saveCursor(root.id, remote.cursor);
    }
    return report;
  }

  FileHasher _preparingHasher(SyncRoot root, Map<String, Manifest> prepared) => (file, relativePath, size) async {
    final activity = _activity!;
    if (size <= LocalScanner.backgroundHashThreshold) return LocalScanner.hashFile(file);
    final cancel = activity.begin(root, relativePath, LocalSyncPhase.preparing, total: size);
    final manifest = await FastCdc.manifestOfFileTracked(
      file,
      onProgress: (bytes) => activity.progress(root.id, relativePath, bytes),
      cancel: cancel,
    );
    activity.progress(root.id, relativePath, manifest.size);
    prepared[relativePath] = manifest;
    return manifest.hash;
  };

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

  Future<SyncRunReport> _executeSafely(
    SyncRoot root,
    SyncAction action,
    Map<String, SyncEntry> synced,
    Map<String, Manifest> prepared,
    CancelToken run,
  ) async {
    try {
      return await _execute(root, action, synced, prepared, run);
    } on SyncCancelledException {
      return const SyncRunReport(deferred: 1);
    } on PathNotFoundException {
      return const SyncRunReport(deferred: 1);
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

  Future<SyncRunReport> _execute(
    SyncRoot root,
    SyncAction action,
    Map<String, SyncEntry> synced,
    Map<String, Manifest> prepared,
    CancelToken run,
  ) async {
    switch (action) {
      case CreateRemoteDirAction(:final path):
        await _executor.createRemoteDir(root, path);
        return const SyncRunReport(uploaded: 1);
      case CreateLocalDirAction(:final path, :final remote):
        await _executor.createLocalDir(root, path, remote);
        return const SyncRunReport(downloaded: 1);
      case UploadAction(:final path, :final local, :final baseRev):
        await _executor.upload(root, path, local, baseRev: baseRev, manifest: prepared[path]);
        return const SyncRunReport(uploaded: 1);
      case DownloadAction(:final path, :final remote):
        await _executor.download(root, path, remote, previous: synced[path], cancel: run);
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
