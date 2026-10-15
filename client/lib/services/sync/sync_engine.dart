import "dart:io";
import "dart:math";

import "package:polder/models/manifest.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/local_file_state.dart";
import "package:polder/models/sync/remote_state.dart";
import "package:polder/models/sync/sync_action.dart";
import "package:polder/models/sync/sync_entry.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/chunker.dart";
import "package:polder/services/sync/conflict_resolver.dart";
import "package:polder/services/sync/delta_downloader.dart";
import "package:polder/services/sync/local_scanner.dart";
import "package:polder/services/sync/reconciler.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/remote_change_set.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/services/sync/sync_executor.dart";
import "package:polder/services/sync/sync_ignore_rules.dart";
import "package:polder/services/sync/sync_paths.dart";
import "package:polder/services/sync/sync_service.dart";
import "package:polder/services/sync/work_queue.dart";
import "package:polder/services/sync/sync_state_store.dart";
import "package:polder/util/remote_path.dart";

typedef RemoteSnapshot = ({Map<String, RemoteState> states, List<RemoteMove> moves, int cursor});

typedef _Location = ({SyncRoot root, String path});

class SyncEngine implements SyncService {
  SyncEngine({
    required PolderApi api,
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

  final PolderApi _api;
  final SyncStateStore _store;
  final SyncActivity? _activity;
  final LocalScanner _scanner;
  final SyncExecutor _executor;
  final DateTime Function() _clock;
  late final ConflictResolver _resolver;

  static final hashWorkers = (Platform.numberOfProcessors - 1).clamp(2, 6);
  static const actionWorkers = 6;
  static const uploadStreams = 2;
  static const maxBatchFiles = 1000;
  static const maxBatchBytes = 64 * 1024 * 1024;
  static const downloadStreams = 2;
  static const maxDownloadBatchFiles = 200;

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
    final scanner = LocalScanner(hasher: _preparingHasher(root, prepared));
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
      if (action is! DownloadAction) _activity?.done(root.id, action.path);
    }

    final firstPass = reconciler.reconcile(
      local: scan.known,
      synced: synced,
      remote: remoteStates,
      pending: {...scan.dirty, ...deferred},
    );
    final firstActions = [...firstPass.where((action) => !action.isDelete && !skipped(action.path))];
    for (final action in firstActions.where((action) => action.isDirectoryCreation)) {
      await execute(action);
    }
    if (!run.isCancelled) {
      _activity?.enqueue(root, [
        for (final action in firstActions)
          if (action is DownloadAction) action.path,
      ], downloads: true);
    }
    final smallDownloads = <DownloadAction>[];
    final others = <SyncAction>[];
    for (final action in firstActions.where((action) => !action.isDirectoryCreation)) {
      if (action is DownloadAction && DeltaDownloader.canBatch(action.remote)) {
        smallDownloads.add(action);
      } else {
        others.add(action);
      }
    }

    Future<void> downloadBatch(List<DownloadAction> batch) async {
      if (run.isCancelled) {
        deferred.addAll([for (final action in batch) action.path]);
        return;
      }
      final failures = await _executor.downloadBatch(root, batch, cancel: run);
      final outcome = _batchReport(root, batch, failures, const SyncRunReport(downloaded: 1));
      report += outcome;
    }

    await Future.wait([
      runPool(others, actionWorkers, execute),
      runPool(_slices(smallDownloads, maxDownloadBatchFiles), downloadStreams, downloadBatch),
    ]);

    Future<void> uploadBatch(List<UploadAction> batch) async {
      if (run.isCancelled) {
        deferred.addAll([for (final action in batch) action.path]);
        return;
      }
      final failures = await _executor.uploadBatch(root, batch, prepared: prepared, run: run);
      final outcome = _batchReport(root, batch, failures, const SyncRunReport(uploaded: 1));
      report += outcome;
    }

    final hashed = <String, LocalFileState>{};
    final actions = AsyncQueue<SyncAction>(capacity: actionWorkers * 2);
    final uploads = BatchQueue<UploadAction>(
      maxItems: maxBatchFiles,
      maxWeight: maxBatchBytes,
      weigh: (action) => action.local.size,
    );
    final hashing =
        runPool(dirty, hashWorkers, (path) async {
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
          switch (reconciler.decide(path, state, synced[path], remoteStates[path])) {
            case final UploadAction upload:
              await uploads.add(upload);
            case final SyncAction action:
              await actions.add(action);
            case null:
              _activity?.done(root.id, path);
          }
        }).whenComplete(() {
          actions.close();
          uploads.close();
        });
    await Future.wait([hashing, actions.drain(actionWorkers, execute), uploads.drain(uploadStreams, uploadBatch)]);
    if (!run.isCancelled) await _executor.discardPausedUploads(root);

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

  /// Stands in for the hash of files skipped by [skipExisting]; once such a file changes it hashes differently
  /// and is uploaded like a new one.
  static const skippedHash = "skipped";

  @override
  Future<void> skipExisting(SyncRoot root) async {
    final directory = Directory(root.localPath);
    if (!await directory.exists()) throw LocalRootMissingException(root.localPath);
    final paths = SyncPaths(root);
    final entries = <SyncEntry>[];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      final relativePath = paths.relativePath(entity.path);
      if (entity is Link || SyncIgnoreRules.isIgnored(relativePath, mode: root.mode)) continue;
      final stat = await entity.stat();
      if (stat.type == FileSystemEntityType.notFound) continue;
      final isDir = entity is Directory;
      entries.add(
        SyncEntry(
          syncRootId: root.id,
          relativePath: relativePath,
          isDir: isDir,
          localHash: isDir ? null : skippedHash,
          localSize: isDir ? null : stat.size,
          localMtime: stat.modified.toUtc(),
          syncedHash: isDir ? "" : skippedHash,
        ),
      );
    }
    await _store.saveEntries(entries);
  }

  FileHasher _preparingHasher(SyncRoot root, Map<String, Manifest> prepared) => (file, relativePath, size) async {
    if (size < FastCdc.minSize) return LocalScanner.hashFile(file);
    final manifest = await _chunkForUpload(root, file, relativePath, size);
    prepared[relativePath] = manifest;
    return manifest.hash;
  };

  Future<Manifest> _chunkForUpload(SyncRoot root, File file, String relativePath, int size) async {
    final activity = _activity;
    if (activity == null) return FastCdc.manifestOfFile(file);
    final cancel = activity.begin(root, relativePath, LocalSyncPhase.preparing, total: size);
    final manifest = await FastCdc.manifestOfFileTracked(
      file,
      onProgress: (bytes) => activity.progress(root.id, relativePath, bytes),
      cancel: cancel,
    );
    activity.progress(root.id, relativePath, manifest.size);
    return manifest;
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

  Future<SyncRunReport> _executeSafely(
    SyncRoot root,
    SyncAction action,
    Map<String, SyncEntry> synced,
    Map<String, Manifest> prepared,
    CancelToken run,
  ) async {
    try {
      return await _execute(root, action, synced, prepared, run);
    } on Exception catch (error) {
      return _reportFailure(root, action, error) ?? (throw error);
    }
  }

  SyncRunReport _batchReport(SyncRoot root, List<SyncAction> batch, List<Exception?> failures, SyncRunReport success) {
    var report = const SyncRunReport();
    for (final (index, failure) in failures.indexed) {
      report += switch (failure) {
        null => success,
        final error =>
          _reportFailure(root, batch[index], error) ?? SyncRunReport.failure("${batch[index].path}: $error"),
      };
    }
    return report;
  }

  static List<List<T>> _slices<T>(List<T> items, int size) => [
    for (var start = 0; start < items.length; start += size) items.sublist(start, min(start + size, items.length)),
  ];

  SyncRunReport? _reportFailure(SyncRoot root, SyncAction action, Exception error) => switch (error) {
    SyncCancelledException() || PathNotFoundException() => const SyncRunReport(deferred: 1),
    ConflictException() => SyncRunReport.conflict(_conflictFromRejection(root, action, error)),
    ApiException() || HashMismatchException() => SyncRunReport.failure("${action.path}: $error"),
    FileSystemException(:final message) => SyncRunReport.failure("${action.path}: $message"),
    _ => null,
  };

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
