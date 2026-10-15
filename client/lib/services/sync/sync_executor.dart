import "dart:convert";
import "dart:io";

import "package:polder/models/file_entry.dart";
import "package:polder/models/manifest.dart";
import "package:polder/models/sync/local_file_state.dart";
import "package:polder/models/sync/sync_action.dart";
import "package:polder/models/sync/sync_entry.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/delta_downloader.dart";
import "package:polder/services/sync/batch_uploader.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_paths.dart";
import "package:polder/services/sync/sync_state_store.dart";

class SyncExecutor {
  SyncExecutor({
    required this._api,
    required this._store,
    this._activity,
    BatchUploader? uploader,
    DeltaDownloader? downloader,
  }) : _uploader = uploader ?? BatchUploader(_api),
       _downloader = downloader ?? DeltaDownloader(_api);

  final PolderApi _api;
  final SyncStateStore _store;
  final SyncActivity? _activity;
  final BatchUploader _uploader;
  final DeltaDownloader _downloader;

  Future<void> createRemoteDir(SyncRoot root, String path) async {
    final remotePath = SyncPaths(root).remotePath(path);
    final entry = await _mkdirOrStat(remotePath);
    final stat = await SyncPaths(root).directory(path).stat();
    await _store.saveEntry(_directoryEntry(root, path, entry, stat.modified));
  }

  Future<void> createLocalDir(SyncRoot root, String path, FileEntry remote) async {
    _activity?.expectWrite(root.id, path);
    final directory = await SyncPaths(root).directory(path).create(recursive: true);
    await _store.saveEntry(_directoryEntry(root, path, remote, (await directory.stat()).modified));
  }

  Future<void> upload(
    SyncRoot root,
    String path,
    LocalFileState local, {
    required int baseRev,
    Manifest? manifest,
  }) async {
    final action = UploadAction(path: path, local: local, baseRev: baseRev);
    final [failure] = await uploadBatch(root, [action], prepared: {path: ?manifest});
    if (failure != null) throw failure;
  }

  Future<List<Exception?>> uploadBatch(
    SyncRoot root,
    List<UploadAction> actions, {
    Map<String, Manifest> prepared = const {},
    CancelToken? run,
  }) async {
    final items = [for (final action in actions) _uploadItem(root, action, prepared[action.path])];
    final outcomes = await _uploader.upload(items, group: root.id, run: run);
    final failures = <Exception?>[];
    for (final (index, outcome) in outcomes.indexed) {
      if (outcome.result case final result?) await _recordUpload(root, actions[index], result);
      failures.add(outcome.error);
    }
    return failures;
  }

  Future<void> discardPausedUploads(SyncRoot root) => _uploader.abortPausedBatches(root.id);

  UploadItem _uploadItem(SyncRoot root, UploadAction action, Manifest? manifest) {
    final paths = SyncPaths(root);
    final activity = _activity;
    return UploadItem(
      source: paths.file(action.path),
      remotePath: paths.remotePath(action.path),
      local: action.local,
      baseRev: action.baseRev,
      manifest: manifest,
      tracking: activity == null
          ? null
          : UploadTracking(
              begin: (phase, total) => activity.begin(root, action.path, phase, total: total),
              progress: (bytes) => activity.progress(root.id, action.path, bytes),
            ),
    );
  }

  Future<void> _recordUpload(SyncRoot root, UploadAction action, UploadResult result) async {
    final local = action.local;
    await _store.saveEntry(
      _fileEntry(
        root,
        action.path,
        result.entry,
        localHash: result.manifest.hash,
        manifest: result.manifest,
        localSize: local.size,
        localMtime: local.mtime,
      ),
    );
    _activity?.done(root.id, action.path);
  }

  Future<void> download(
    SyncRoot root,
    String path,
    FileEntry remote, {
    SyncEntry? previous,
    CancelToken? cancel,
  }) async {
    _activity?.expectWrite(root.id, path);
    final target = SyncPaths(root).file(path);
    await target.parent.create(recursive: true);
    final activity = _activity;
    activity?.begin(root, path, LocalSyncPhase.downloading, total: remote.size);
    var received = 0;
    final downloaded = await _downloader.download(
      remote: remote,
      target: target,
      localManifest: _decodeManifest(previous?.manifestJson),
      cancel: cancel,
      onReceived: activity == null
          ? null
          : (bytes) {
              activity
                ..downloaded(bytes)
                ..progress(root.id, path, received += bytes);
            },
    );
    await _recordDownload(root, path, remote, downloaded);
  }

  Future<List<Exception?>> downloadBatch(SyncRoot root, List<DownloadAction> actions, {CancelToken? cancel}) async {
    final paths = SyncPaths(root);
    for (final action in actions) {
      _activity
        ?..expectWrite(root.id, action.path)
        ..begin(root, action.path, LocalSyncPhase.downloading, total: action.remote.size);
    }
    final outcomes = await _downloader.downloadBatch(
      [for (final action in actions) (remote: action.remote, target: paths.file(action.path))],
      cancel: cancel,
      onReceived: _activity?.downloaded,
    );
    final failures = <Exception?>[];
    for (final (index, outcome) in outcomes.indexed) {
      final action = actions[index];
      if (outcome.result case final result?) await _recordDownload(root, action.path, action.remote, result);
      failures.add(outcome.error);
    }
    return failures;
  }

  Future<void> _recordDownload(SyncRoot root, String path, FileEntry remote, DownloadResult downloaded) async {
    final stat = await SyncPaths(root).file(path).stat();
    await _store.saveEntry(
      _fileEntry(
        root,
        path,
        remote,
        localHash: downloaded.hash,
        manifest: downloaded.manifest,
        localSize: stat.size,
        localMtime: stat.modified,
      ),
    );
    _activity?.done(root.id, path);
  }

  /// Moves an unchanged local file to where the server moved it, possibly into another sync root, and carries
  /// its sync state along. When the content also changed remotely the old rev is kept, so the next reconcile
  /// downloads the difference against the moved file.
  Future<void> relocate({
    required SyncRoot fromRoot,
    required SyncEntry previous,
    required SyncRoot toRoot,
    required String toPath,
    required FileEntry remote,
  }) async {
    final target = SyncPaths(toRoot).file(toPath);
    _activity
      ?..expectWrite(fromRoot.id, previous.relativePath)
      ..expectWrite(toRoot.id, toPath);
    await target.parent.create(recursive: true);
    await SyncPaths(fromRoot).file(previous.relativePath).rename(target.path);
    final unchanged = remote.hash == previous.syncedHash;
    await _store.saveEntry(
      previous.copyWith(
        syncRootId: toRoot.id,
        relativePath: toPath,
        syncedRev: unchanged ? remote.rev : previous.syncedRev,
      ),
    );
    await _store.deleteEntryTree(fromRoot.id, previous.relativePath);
  }

  Future<void> deleteLocal(SyncRoot root, String path) async {
    _activity?.expectWrite(root.id, path);
    final paths = SyncPaths(root);
    final type = await FileSystemEntity.type(paths.localPath(path), followLinks: false);
    if (type == FileSystemEntityType.directory) await paths.directory(path).delete(recursive: true);
    if (type == FileSystemEntityType.file) await paths.file(path).delete();
    await _store.deleteEntryTree(root.id, path);
  }

  Future<void> deleteRemote(SyncRoot root, String path, {required int baseRev}) async {
    try {
      await _api.delete(SyncPaths(root).remotePath(path), baseRev: baseRev);
    } on NotFoundException {
      return _store.deleteEntryTree(root.id, path);
    }
    await _store.deleteEntryTree(root.id, path);
  }

  Future<void> recordSynced(SyncRoot root, String path, LocalFileState local, FileEntry remote) => _store.saveEntry(
    SyncEntry(
      syncRootId: root.id,
      relativePath: path,
      isDir: remote.isDir,
      localHash: local.isDir ? null : local.hash,
      localSize: local.isDir ? null : local.size,
      localMtime: local.mtime,
      syncedRev: remote.rev,
      syncedHash: remote.hash,
    ),
  );

  Future<void> savePlaceholder(SyncRoot root, String path, FileEntry remote) => _store.saveEntry(
    SyncEntry(
      syncRootId: root.id,
      relativePath: path,
      isDir: remote.isDir,
      syncedRev: remote.rev,
      syncedHash: remote.hash,
      state: EntryState.placeholder,
    ),
  );

  Future<void> forget(SyncRoot root, String path) => _store.deleteEntryTree(root.id, path);

  Future<FileEntry> _mkdirOrStat(String remotePath) async {
    try {
      return await _api.mkdir(remotePath);
    } on AlreadyExistsException {
      return _api.stat(remotePath);
    }
  }

  SyncEntry _directoryEntry(SyncRoot root, String path, FileEntry remote, DateTime localMtime) => SyncEntry(
    syncRootId: root.id,
    relativePath: path,
    isDir: true,
    localMtime: localMtime.toUtc(),
    syncedRev: remote.rev,
  );

  SyncEntry _fileEntry(
    SyncRoot root,
    String path,
    FileEntry remote, {
    required String localHash,
    required Manifest? manifest,
    required int localSize,
    required DateTime localMtime,
  }) => SyncEntry(
    syncRootId: root.id,
    relativePath: path,
    localHash: localHash,
    localSize: localSize,
    localMtime: localMtime.toUtc(),
    syncedRev: remote.rev,
    syncedHash: remote.hash.isEmpty ? localHash : remote.hash,
    manifestJson: manifest == null ? null : jsonEncode(manifest.toJson()),
  );

  Manifest? _decodeManifest(String? json) =>
      json == null ? null : Manifest.fromJson(jsonDecode(json) as Map<String, dynamic>);
}
