import "dart:convert";
import "dart:io";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/manifest.dart";
import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/delta_downloader.dart";
import "package:nomad/services/sync/delta_uploader.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_paths.dart";
import "package:nomad/services/sync/sync_state_store.dart";

class SyncExecutor {
  SyncExecutor({
    required this._api,
    required this._store,
    this._activity,
    DeltaUploader? uploader,
    DeltaDownloader? downloader,
  }) : _uploader = uploader ?? DeltaUploader(_api),
       _downloader = downloader ?? DeltaDownloader(_api);

  final NomadApi _api;
  final SyncStateStore _store;
  final SyncActivity? _activity;
  final DeltaUploader _uploader;
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
    final paths = SyncPaths(root);
    final activity = _activity;
    final result = await _uploader.upload(
      source: paths.file(path),
      remotePath: paths.remotePath(path),
      baseRev: baseRev,
      mtime: local.mtime,
      manifest: manifest,
      tracking: activity == null
          ? null
          : UploadTracking(
              begin: (phase, total) => activity.begin(root, path, phase, total: total),
              progress: (bytes) => activity.progress(root.id, path, bytes),
            ),
    );
    await _store.saveEntry(
      _fileEntry(root, path, result.entry, result.manifest, localSize: local.size, localMtime: local.mtime),
    );
    activity?.done(root.id, path);
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
    final manifest = await _downloader.download(
      remotePath: remote.path,
      target: target,
      localManifest: _decodeManifest(previous?.manifestJson),
      mtime: remote.mtime,
      cancel: cancel,
    );
    final stat = await target.stat();
    await _store.saveEntry(_fileEntry(root, path, remote, manifest, localSize: stat.size, localMtime: stat.modified));
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
    FileEntry remote,
    Manifest manifest, {
    required int localSize,
    required DateTime localMtime,
  }) => SyncEntry(
    syncRootId: root.id,
    relativePath: path,
    localHash: manifest.hash,
    localSize: localSize,
    localMtime: localMtime.toUtc(),
    syncedRev: remote.rev,
    syncedHash: remote.hash.isEmpty ? manifest.hash : remote.hash,
    manifestJson: jsonEncode(manifest.toJson()),
  );

  Manifest? _decodeManifest(String? json) =>
      json == null ? null : Manifest.fromJson(jsonDecode(json) as Map<String, dynamic>);
}
