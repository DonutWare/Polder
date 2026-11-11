import "dart:async";
import "dart:math";
import "dart:typed_data";

import "package:mime/mime.dart";

import "package:polder/models/change.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/content_store.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/services/offline/outbox_errors.dart";
import "package:polder/services/offline/streaming_content_downloader.dart";
import "package:polder/util/async_lock.dart";
import "package:polder/util/remote_path.dart";

enum OfflineWork { push, pull, mirror }

class OfflineDownload {
  const OfflineDownload({required this.path, required this.received, required this.total});

  final String path;
  final int received;
  final int total;

  double? get progress => total <= 0 ? null : (received / total).clamp(0.0, 1.0);

  int get countedBytes => total <= 0 ? 0 : min(max(received, 0), total);
}

typedef DownloadFailure = ({Object error, int attempts, DateTime retryAt});

class OfflineFiles {
  OfflineFiles({
    required PolderApi api,
    required this._store,
    required OfflineContentStore content,
    ContentDownloader? downloader,
    void Function(OfflineWork work)? onWork,
    this._clock = DateTime.now,
  }) : _api = api,
       _content = content,
       _onWork = onWork ?? _ignoreWork,
       _downloader = downloader ?? StreamingContentDownloader(api: api, content: content) {
    _downloadEvents;
  }

  static const downloadWindow = 8;
  static const freshContentAge = Duration(minutes: 10);
  static const garbageInterval = Duration(minutes: 10);

  final PolderApi _api;
  final OfflineStore _store;
  final OfflineContentStore _content;
  final ContentDownloader _downloader;
  final void Function(OfflineWork work) _onWork;
  final DateTime Function() _clock;
  final _lock = AsyncLock();
  final _inFlight = <int>{};
  final _freshHashes = <String, DateTime>{};
  final _active = <String, OfflineDownload>{};
  final _failed = <String, DownloadFailure>{};
  final _cancelled = <String>{};
  final _downloadsChanged = StreamController<void>.broadcast();
  DateTime? _collectedAt;
  late final StreamSubscription<ContentDownloadEvent> _downloadEvents = _downloader.events.listen(_onDownloadEvent);

  static void _ignoreWork(OfflineWork work) {}

  Stream<void> get changes => _store.changes;

  Stream<void> get downloadsChanged => _downloadsChanged.stream;

  Map<String, OfflineDownload> get activeDownloads => Map.unmodifiable(_active);

  Map<String, DownloadFailure> get failedDownloads => Map.unmodifiable(_failed);

  Future<OfflineFile?> file(String path) => _store.file(path);

  Future<List<OfflineFile>> children(String path) => _store.children(path);

  Future<List<OfflineFile>> filesWithIds(Iterable<int> ids) => _store.filesWithIds(ids);

  Future<List<OfflineFile>> tree(String path) => _store.tree(path);

  Future<List<OfflinePin>> pins() => _store.pins();

  Future<OfflineCounts> counts(String path, {Iterable<String> skip = const []}) => _store.counts(path, skip: skip);

  Future<Uint8List?> read(String path) async {
    final hash = (await _store.file(path))?.localHash;
    return hash == null ? null : _content.read(hash);
  }

  Future<Uint8List?> readMatching(FileEntry entry) async {
    final row = await _store.file(entry.path);
    final hash = row?.localHash;
    if (row == null || hash == null) return null;
    if (!row.unsynced && hash != entry.hash) return null;
    return _content.read(hash);
  }

  Future<bool> availableOffline(String path) async =>
      (await _store.pins()).any((pin) => pin.mirrors && pin.populated && pin.covers(path));

  Future<OfflineFile> fetch(String path) async {
    final entry = await _api.stat(path);
    final hash = entry.isDir ? null : _remember(await _content.writeStream(await _api.downloadStream(path)));
    return _lock.run(() async {
      final current = await _store.file(path);
      if (current != null && current.unsynced) return current;
      final row = OfflineFile.fromServer(entry, localHash: hash == entry.hash ? hash : null);
      await _store.saveFile(row);
      return row;
    });
  }

  Future<OfflineFile> write(String path, Uint8List bytes, {DateTime? mtime}) async {
    final hash = _remember(await _content.write(bytes));
    return _queued(_lock.run(() => _recordWrite(path, hash, bytes.length, mtime, transient: false)));
  }

  Future<OfflineFile> queueUpload(String path, Stream<List<int>> bytes, {DateTime? mtime}) async {
    final hash = _remember(await _content.writeStream(bytes));
    final size = await _content.length(hash) ?? 0;
    return _queued(_lock.run(() => _recordWrite(path, hash, size, mtime, transient: true)));
  }

  Future<void> move(String from, String to) => _queued(
    _lock.run(() async {
      if (from == to) return;
      final row = await _store.file(from);
      if (row == null) throw const NotFoundException();
      if (await _store.file(to) != null) throw const AlreadyExistsException();
      await _store.batch(() async {
        final pending = await _store.outboxFor(from);
        await _moveRows(from, to, pending: true);
        if (!row.onServer) {
          for (final entry in pending) {
            await _store.saveEntry(entry.copyWith(op: _relocated(entry.op, from, to)));
          }
          return;
        }
        await _store.enqueue(
          OutboxOp.move(from: from, to: to),
          at: _clock(),
        );
        for (final entry in pending.where((entry) => !_inFlight.contains(entry.id))) {
          await _store.removeEntry(entry.id);
          await _store.enqueue(_relocated(entry.op, from, to), at: entry.createdAt);
        }
      });
    }),
  );

  Future<void> delete(String path) => _queued(
    _lock.run(() async {
      final row = await _store.file(path);
      if (row == null) return;
      await _store.batch(() async {
        for (final entry in await _store.outboxFor(path)) {
          if (entry.op is MoveOp || _inFlight.contains(entry.id)) continue;
          await _store.removeEntry(entry.id);
        }
        await _store.deleteTree(path);
        if (row.onServer) {
          await _store.enqueue(
            OutboxOp.delete(path: path, baseRev: row.isDir ? -1 : row.baseRev),
            at: _clock(),
          );
        }
      });
    }),
  );

  Future<void> pinNotes(String? folder) async {
    final removed = await _lock.run(() async {
      final notes = (await _store.pins()).ofKind(OfflinePinKind.notes).toList();
      final stale = [
        for (final pin in notes)
          if (pin.path != folder) pin.path,
      ];
      for (final path in stale) {
        await _store.deletePin(path);
      }
      if (folder != null && !notes.any((pin) => pin.path == folder)) {
        await _store.savePin(OfflinePin(path: folder, kind: OfflinePinKind.notes));
        _onWork(OfflineWork.pull);
      }
      return stale;
    });
    for (final path in removed) {
      await _forget(path);
    }
  }

  Future<void> makeAvailableOffline(String path) async {
    await _lock.run(() async {
      final pins = await _store.pins();
      final governing = pins.governing(path);
      if (governing?.kind == OfflinePinKind.notes) return;
      for (final nested in pins.nestedIn(path).where((pin) => pin.kind != OfflinePinKind.notes)) {
        await _store.deletePin(nested.path);
      }
      if (governing?.kind == OfflinePinKind.excluded && governing!.path == path) {
        await _store.deletePin(path);
      } else if (governing?.kind != OfflinePinKind.user) {
        await _store.savePin(OfflinePin(path: path, kind: OfflinePinKind.user));
      }
    });
    _forgetFailuresUnder(path);
    _onWork(OfflineWork.mirror);
  }

  Future<void> removeFromDevice(String path) async {
    final pins = await _store.pins();
    final governing = pins.governing(path);
    if (governing == null || governing.kind != OfflinePinKind.user) return;
    await _cancelDownloadsUnder(path);
    await _lock.run(() async {
      for (final nested in pins.nestedIn(path).where((pin) => pin.kind != OfflinePinKind.notes)) {
        await _store.deletePin(nested.path);
      }
      if (governing.path == path) {
        await _store.deletePin(path);
      } else {
        await _store.savePin(OfflinePin(path: path, kind: OfflinePinKind.excluded, populated: true));
      }
    });
    _forgetFailuresUnder(path);
    await _forget(path);
    _onWork(OfflineWork.mirror);
  }

  Future<void> retryNow() async {
    await _lock.run(() async {
      for (final entry in await _store.outbox(OutboxDomain.files)) {
        if (entry.error?.kind.retries ?? entry.nextAttemptAt != null) {
          await _store.saveEntry(entry.copyWith(nextAttemptAt: null));
        }
      }
    });
    _failed.clear();
    _announceDownloads();
    _onWork(OfflineWork.push);
    _onWork(OfflineWork.pull);
    _onWork(OfflineWork.mirror);
  }

  Future<void> discard(String path) => _lock.run(() async {
    final row = await _store.file(path);
    await _store.batch(() async {
      for (final entry in await _store.outboxFor(path)) {
        if (!_inFlight.contains(entry.id)) await _store.removeEntry(entry.id);
      }
      if (row == null) return;
      if (row.onServer || row.conflict?.server != null) {
        await _store.saveFile(OfflineFile.fromServer(row.conflict?.server ?? row.entry.copyWith(rev: row.baseRev)));
      } else {
        await _store.deleteTree(path);
      }
    });
  });

  Future<String?> resolve(String path, ConflictResolution resolution, {String? copyPath}) => _queued(
    _lock.run(() async {
      final row = await _store.file(path);
      final conflict = row?.conflict;
      if (row == null || conflict == null) return null;
      switch (resolution) {
        case ConflictResolution.keepMine:
          await _keepMine(row, conflict);
          return path;
        case ConflictResolution.keepServer:
          await _keepServer(row, conflict);
          return path;
        case ConflictResolution.keepBoth:
          return _keepBoth(row, conflict, copyPath);
      }
    }),
  );

  Future<DateTime?> push() async {
    final blocked = <String>[];
    final handled = <int>{};
    while (true) {
      final entry = await _nextQueued(handled, blocked);
      if (entry == null) return null;
      handled.add(entry.id);
      if (entry.blocked) {
        blocked.addAll(_pathsOf(entry.op));
        continue;
      }
      if (!entry.readyAt(_clock())) return entry.nextAttemptAt;
      _inFlight.add(entry.id);
      try {
        final result = await _execute(entry);
        await _lock.run(() => _complete(entry, result));
      } on Object catch (error) {
        final failure = OutboxErrors.classify(error);
        final retryNow = await _lock.run(() => _fail(entry, error, failure));
        if (retryNow) return _clock();
        if (failure.kind.retries) return _clock().add(OutboxErrors.retryDelay(entry.attempts + 1));
        blocked.addAll(_pathsOf(entry.op));
      } finally {
        _inFlight.remove(entry.id);
      }
    }
  }

  Future<OutboxEntry?> _nextQueued(Set<int> handled, List<String> blocked) async => [
    for (final entry in await _store.outbox(OutboxDomain.files))
      if (!handled.contains(entry.id) &&
          !_inFlight.contains(entry.id) &&
          !blocked.any((path) => _touches(entry.op, path)))
        entry,
  ].firstOrNull;

  Future<void> pull() async {
    final pins = await _store.pins();
    if (!pins.any((pin) => pin.mirrors)) return;
    final cursor = await _ensureCursor();
    if (cursor != null) await _applyFeed(cursor);
    for (final pin in pins.ofKind(OfflinePinKind.notes).where((pin) => !pin.populated)) {
      await _populate(pin);
    }
    await _downloadNotes();
    _onWork(OfflineWork.mirror);
  }

  Future<DateTime?> mirror() async {
    Object? failure;
    for (final pin in (await _store.pins()).ofKind(OfflinePinKind.user).where((pin) => !pin.populated)) {
      try {
        await _ensureCursor();
        await _populate(pin);
      } on Object catch (error) {
        failure ??= error;
      }
    }
    final retryAt = await _topUpDownloads();
    if (failure != null) throw failure;
    return retryAt;
  }

  Future<void> whenDownloadsSettle() async {
    while (_active.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await _lock.run(() async {});
  }

  Future<void> collectGarbage() => _lock.run(() async {
    final now = _clock();
    _collectedAt = now;
    _freshHashes.removeWhere((_, at) => now.difference(at) > freshContentAge);
    await _content.retainOnly({...await _store.referencedHashes(), ..._freshHashes.keys});
  });

  Future<void> dispose() async {
    await _downloadEvents.cancel();
    await _downloadsChanged.close();
  }

  Future<T> _queued<T>(Future<T> work) async {
    final result = await work;
    _onWork(OfflineWork.push);
    return result;
  }

  String _remember(String hash) {
    _freshHashes[hash] = _clock();
    return hash;
  }

  Future<int?> _ensureCursor() async {
    final cursor = await _store.cursor();
    if (cursor != null) return cursor;
    await _store.saveCursor((await _api.changes(cursor: -1)).cursor);
    return null;
  }

  Future<void> _downloadNotes() async {
    final pins = await _store.pins();
    Object? failure;
    for (final pin in pins.ofKind(OfflinePinKind.notes)) {
      final missing = await _store.missingContent(
        pin.path,
        skip: [for (final nested in pins.nestedIn(pin.path)) nested.path],
        maxSize: OfflinePin.notesContentLimit,
      );
      for (final row in missing) {
        try {
          final hash = _remember(await _content.writeStream(await _api.downloadStream(row.path)));
          await _lock.run(() => _storeDownloaded(row.path, hash));
        } on Object catch (error) {
          failure ??= error;
        }
      }
    }
    if (failure != null) throw failure;
  }

  Future<DateTime?> _topUpDownloads() async {
    final pins = await _store.pins();
    final queued = await _cancelUnwanted(pins, await _downloader.queued());
    await _trackQueued(queued);
    final now = _clock();
    final inFlight = {...queued, ..._active.keys};
    var free = downloadWindow - inFlight.length;
    for (final pin in pins.ofKind(OfflinePinKind.user)) {
      if (free <= 0) break;
      final missing = await _store.missingContent(
        pin.path,
        skip: [for (final nested in pins.nestedIn(pin.path)) nested.path],
        limit: downloadWindow + inFlight.length + _failed.length,
      );
      for (final row in missing) {
        if (free <= 0) break;
        if (inFlight.contains(row.path) || (_failed[row.path]?.retryAt.isAfter(now) ?? false)) continue;
        await _enqueue(row);
        free--;
      }
    }
    _announceDownloads();
    if (_active.isEmpty && _isGarbageDue(now)) {
      await collectGarbage();
      await _downloader.clearLeftovers();
    }
    return _failed.values
        .map((failure) => failure.retryAt)
        .where((at) => at.isAfter(now))
        .fold<DateTime?>(null, (earliest, at) => earliest == null || at.isBefore(earliest) ? at : earliest);
  }

  Future<void> _enqueue(OfflineFile row) async {
    _cancelled.remove(row.path);
    _active[row.path] = OfflineDownload(path: row.path, received: 0, total: row.entry.size);
    try {
      await _downloader.enqueue(row);
    } on Object {
      _active.remove(row.path);
      _announceDownloads();
      rethrow;
    }
  }

  Future<Set<String>> _cancelUnwanted(List<OfflinePin> pins, Set<String> queued) async {
    final wanted = <String>{};
    for (final path in queued) {
      final row = await _store.file(path);
      if (row != null && !row.contentReady && pins.wantsContent(path, row.entry.size)) {
        wanted.add(path);
      } else {
        _cancelled.add(path);
        _active.remove(path);
        await _downloader.cancel(path);
      }
    }
    return wanted;
  }

  bool _isGarbageDue(DateTime now) => _collectedAt == null || now.difference(_collectedAt!) > garbageInterval;

  Future<void> _trackQueued(Set<String> queued) async {
    for (final path in queued.where((path) => !_active.containsKey(path))) {
      final row = await _store.file(path);
      _active[path] = OfflineDownload(path: path, received: 0, total: row?.entry.size ?? 0);
    }
  }

  void _onDownloadEvent(ContentDownloadEvent event) {
    final path = event.path;
    switch (event) {
      case ContentDownloadProgress(:final received, :final total, :final fraction):
        final known = total > 0 ? total : (_active[path]?.total ?? 0);
        final bytes = total > 0 || fraction == null ? received : (fraction * known).round();
        _active[path] = OfflineDownload(path: path, received: max(bytes, 0), total: known);
        _announceDownloads();
        return;
      case ContentDownloadDone(:final hash):
        _remember(hash);
        unawaited(_finishDownload(path, hash));
        return;
      case ContentDownloadFailed(:final error):
        _active.remove(path);
        if (!_cancelled.remove(path)) _recordFailure(path, error);
    }
    _announceDownloads();
    _onWork(OfflineWork.mirror);
  }

  Future<void> _finishDownload(String path, String hash) async {
    try {
      if (await _lock.run(() => _storeDownloaded(path, hash))) {
        _failed.remove(path);
      } else {
        _recordFailure(path, const ServerDidNotStoreException("the file changed on the server while it downloaded"));
      }
    } on Object catch (error) {
      _recordFailure(path, error);
    } finally {
      _active.remove(path);
      _announceDownloads();
      _onWork(OfflineWork.mirror);
    }
  }

  void _recordFailure(String path, Object error) {
    final attempts = (_failed[path]?.attempts ?? 0) + 1;
    _failed[path] = (
      error: OutboxErrors.classify(error),
      attempts: attempts,
      retryAt: _clock().add(OutboxErrors.retryDelay(attempts)),
    );
  }

  Future<bool> _storeDownloaded(String path, String hash) async {
    final current = await _store.file(path);
    if (current == null || current.unsynced) return true;
    if (!(await _store.pins()).wantsContent(path, current.entry.size)) return true;
    if (current.entry.hash != hash) return false;
    await _store.saveFile(current.copyWith(localHash: hash));
    return true;
  }

  Future<void> _cancelDownloadsUnder(String path) async {
    for (final queued in await _downloader.queued()) {
      if (queued == path || RemotePath.isWithin(queued, path)) {
        _cancelled.add(queued);
        _active.remove(queued);
        await _downloader.cancel(queued);
      }
    }
    _announceDownloads();
  }

  void _forgetFailuresUnder(String path) {
    _failed.removeWhere((failed, _) => failed == path || RemotePath.isWithin(failed, path));
    _announceDownloads();
  }

  void _announceDownloads() {
    if (!_downloadsChanged.isClosed) _downloadsChanged.add(null);
  }

  Future<void> _forget(String path) => _lock.run(() async {
    final pins = await _store.pins();
    await _store.batch(() async {
      for (final row in await _store.tree(path)) {
        if (row.unsynced || (await _store.outboxFor(row.path)).isNotEmpty) continue;
        if (!pins.mirrors(row.path)) {
          await _store.deleteFile(row.path);
        } else if (row.localHash != null && !pins.wantsContent(row.path, row.entry.size)) {
          await _store.saveFile(row.copyWith(localHash: null));
        }
      }
    });
  });

  Future<OfflineFile> _recordWrite(
    String path,
    String hash,
    int size,
    DateTime? mtime, {
    required bool transient,
  }) async {
    final existing = await _store.file(path);
    if (existing != null && existing.isDir) throw const AlreadyExistsException();
    if (existing != null && existing.localHash == hash && existing.entry.hash == hash) return existing;
    final base = existing ?? OfflineFile(entry: _newEntry(path, isDir: false), transient: transient);
    final updated = base.copyWith(
      entry: base.entry.copyWith(hash: hash, size: size, mtime: mtime ?? _clock()),
      localHash: hash,
      state: base.state == OfflineFileState.conflict ? OfflineFileState.conflict : OfflineFileState.pending,
      error: null,
    );
    final op = OutboxOp.put(path: path, hash: hash, size: size);
    await _store.batch(() async {
      await _store.saveFile(updated);
      final queued = (await _store.outboxFor(path)).lastOrNull;
      if (queued != null && queued.op is PutOp && queued.path == path && !_inFlight.contains(queued.id)) {
        await _store.saveEntry(queued.copyWith(op: op));
      } else {
        await _store.enqueue(op, at: _clock());
      }
    });
    return updated;
  }

  Future<FileEntry?> _execute(OutboxEntry entry) async => switch (entry.op) {
    PutOp() && final op => _executePut(op),
    MoveOp(:final from, :final to) => _executeMove(from, to),
    DeleteOp(:final path, :final baseRev) => _executeDelete(path, baseRev),
    CalendarOp() => null,
  };

  Future<FileEntry?> _executePut(PutOp op) async {
    final row = await _store.file(op.path);
    if (row == null) return null;
    final length = await _content.length(op.hash);
    if (length == null) throw MissingContentException(op.hash);
    final stored = await _api.putContent(
      op.path,
      _content.openRead(op.hash),
      length: length,
      baseRev: row.baseRev,
      mtime: row.entry.mtime,
    );
    if (stored.hash != op.hash || stored.size != op.size) {
      throw ServerDidNotStoreException(
        "sent ${op.size} bytes with hash ${op.hash}, the server kept ${stored.size} bytes with hash ${stored.hash}",
      );
    }
    return stored;
  }

  Future<FileEntry?> _executeMove(String from, String to) async {
    final row = await _store.file(to);
    try {
      return await _api.move(from: from, to: to, baseRev: row == null || row.isDir ? -1 : row.baseRev);
    } on NotFoundException {
      final arrived = await _statOrNull(to);
      if (arrived != null && arrived.hash == row?.baseHash) return arrived;
      rethrow;
    }
  }

  Future<FileEntry?> _executeDelete(String path, int baseRev) async {
    try {
      await _api.delete(path, baseRev: baseRev);
    } on NotFoundException {
      return null;
    }
    return null;
  }

  Future<FileEntry?> _statOrNull(String path) async {
    try {
      return await _api.stat(path);
    } on NotFoundException {
      return null;
    }
  }

  Future<void> _complete(OutboxEntry entry, FileEntry? stored) => _store.batch(() async {
    final current = (await _store.outbox(OutboxDomain.files)).where((other) => other.id == entry.id).firstOrNull;
    if (current == null || current.op == entry.op) await _store.removeEntry(entry.id);
    if (stored == null) return;
    final row = await _store.file(stored.path);
    if (row == null) return;
    final stillPending = (await _store.outboxFor(stored.path)).any((other) => other.path == stored.path);
    final localChanged = !row.isDir && row.entry.hash != stored.hash;
    if (!stillPending && row.transient && !(await _store.pins()).mirrors(stored.path)) {
      return _store.deleteFile(stored.path);
    }
    await _store.saveFile(
      row.copyWith(
        entry: localChanged ? row.entry.copyWith(id: stored.id, rev: stored.rev, mime: stored.mime) : stored,
        baseRev: stored.rev,
        baseHash: stored.hash,
        localHash: row.isDir ? null : row.localHash,
        state: stillPending ? OfflineFileState.pending : OfflineFileState.synced,
        conflict: null,
        error: null,
      ),
    );
  });

  Future<bool> _fail(OutboxEntry entry, Object error, OutboxError failure) => _store.batch(() async {
    if (failure.kind == OutboxErrorKind.conflict) return _conflict(entry, error, failure);
    await _store.saveEntry(
      entry.copyWith(
        attempts: entry.attempts + 1,
        nextAttemptAt: failure.kind.retries ? _clock().add(OutboxErrors.retryDelay(entry.attempts + 1)) : null,
        error: failure,
      ),
    );
    final row = await _store.file(entry.path);
    if (row != null && row.state != OfflineFileState.conflict) {
      await _store.saveFile(row.copyWith(state: OfflineFileState.failed, error: failure));
    }
    return false;
  });

  Future<bool> _conflict(OutboxEntry entry, Object error, OutboxError failure) async {
    final server = switch (error) {
      ConflictException(:final current) => current,
      _ => await _statOrNull(entry.path),
    };
    final row = await _store.file(entry.path);
    if (entry.op case PutOp(:final hash) when server != null && server.hash == hash) {
      await _complete(entry, server);
      return false;
    }
    if (entry.op is PutOp && server == null && row != null && await _followRename(entry, row)) return true;
    await _store.saveEntry(entry.copyWith(attempts: entry.attempts + 1, error: failure));
    final conflict = OfflineConflict(server: server, deletedHere: entry.op is DeleteOp, detectedAt: _clock());
    final base = row ?? OfflineFile.fromServer(server ?? _newEntry(entry.path, isDir: false));
    await _store.saveFile(base.copyWith(state: OfflineFileState.conflict, conflict: conflict, error: failure));
    return false;
  }

  Future<bool> _followRename(OutboxEntry entry, OfflineFile row) async {
    if (row.entry.id <= 0) return false;
    final List<FileEntry> found;
    try {
      found = await _api.filesById([row.entry.id]);
    } on ApiException {
      return false;
    }
    final moved = found.where((candidate) => candidate.path != row.path && !candidate.isDir).firstOrNull;
    if (moved == null || moved.hash != row.baseHash || await _store.file(moved.path) != null) return false;
    await _moveRows(row.path, moved.path, pending: true);
    final relocated = await _store.file(moved.path);
    if (relocated != null) {
      await _store.saveFile(
        relocated.copyWith(
          baseRev: moved.rev,
          entry: relocated.entry.copyWith(rev: moved.rev),
        ),
      );
    }
    await _store.saveEntry(entry.copyWith(op: _relocated(entry.op, row.path, moved.path), nextAttemptAt: null));
    return true;
  }

  Future<void> _keepMine(OfflineFile row, OfflineConflict conflict) => _store.batch(() async {
    final server = conflict.server;
    for (final entry in await _store.outboxFor(row.path)) {
      final op = switch (entry.op) {
        DeleteOp(:final path) => OutboxOp.delete(path: path, baseRev: server?.rev ?? -1),
        final op => op,
      };
      await _store.saveEntry(entry.copyWith(op: op, error: null, nextAttemptAt: null, attempts: 0));
    }
    if (conflict.deletedHere) return _store.deleteFile(row.path);
    final queued = await _store.outboxFor(row.path);
    final hash = row.localHash;
    if (server == null && hash != null && !queued.any((entry) => entry.op is PutOp)) {
      await _store.enqueue(
        OutboxOp.put(path: row.path, hash: hash, size: row.entry.size),
        at: _clock(),
      );
    }
    await _store.saveFile(
      row.copyWith(
        baseRev: server?.rev ?? 0,
        baseHash: server?.hash ?? "",
        state: OfflineFileState.pending,
        conflict: null,
        error: null,
      ),
    );
  });

  Future<void> _keepServer(OfflineFile row, OfflineConflict conflict) => _store.batch(() async {
    for (final entry in await _store.outboxFor(row.path)) {
      if (!_inFlight.contains(entry.id)) await _store.removeEntry(entry.id);
    }
    final server = conflict.server;
    if (server == null) return _store.deleteTree(row.path);
    await _store.saveFile(OfflineFile.fromServer(server));
  });

  Future<String?> _keepBoth(OfflineFile row, OfflineConflict conflict, String? requestedCopyPath) async {
    final hash = row.localHash;
    if (conflict.deletedHere || hash == null) {
      await _keepServer(row, conflict);
      return row.path;
    }
    final copyPath = requestedCopyPath ?? await _conflictCopyPath(row.path);
    await _store.batch(() async {
      await _keepServer(row, conflict);
      await _store.saveFile(
        OfflineFile(
          entry: row.entry.copyWith(path: copyPath, name: RemotePath.name(copyPath), id: 0, rev: 0),
          localHash: hash,
          state: OfflineFileState.pending,
        ),
      );
      await _store.enqueue(
        OutboxOp.put(path: copyPath, hash: hash, size: row.entry.size),
        at: _clock(),
      );
    });
    return copyPath;
  }

  Future<String> _conflictCopyPath(String path) async {
    final parent = RemotePath.parent(path);
    final name = RemotePath.name(path);
    final base = RemotePath.withoutExtension(name);
    final extension = RemotePath.extension(name);
    final taken = {for (final sibling in await _store.children(parent)) sibling.entry.name};
    for (var attempt = 1; ; attempt++) {
      final suffix = attempt == 1 ? " (conflict)" : " (conflict $attempt)";
      final candidate = extension.isEmpty ? "$base$suffix" : "$base$suffix.$extension";
      if (!taken.contains(candidate)) return RemotePath.join(parent, candidate);
    }
  }

  Future<void> _applyFeed(int cursor) async {
    final changes = <Change>[];
    var next = cursor;
    var hasMore = true;
    while (hasMore) {
      final page = await _api.changes(cursor: next);
      changes.addAll(page.changes);
      next = page.cursor;
      hasMore = page.hasMore;
    }
    final pins = await _store.pins();
    final arrivedFolders = await _lock.run(() => _store.batch(() => _applyChanges(changes, pins)));
    for (final folder in arrivedFolders) {
      await _listInto(folder);
    }
    await _store.saveCursor(next);
  }

  Future<List<String>> _applyChanges(List<Change> changes, List<OfflinePin> pins) async {
    final arrivedFolders = <String>[];
    for (final change in changes) {
      switch (change) {
        case Change(type: ChangeType.upsert, :final entry?):
          if (pins.mirrors(change.path) || await _store.file(change.path) != null) await _applyRemote(entry);
        case Change(type: ChangeType.delete):
          await _forgetSynced(change.path);
        case Change(type: ChangeType.move, :final fromPath?):
          final moved = await _moveSynced(fromPath, change.path, pins);
          final entry = change.entry;
          if (entry != null && pins.mirrors(change.path)) {
            await _applyRemote(entry);
            if (!moved && entry.isDir) arrivedFolders.add(change.path);
          }
        case _:
          break;
      }
    }
    return arrivedFolders;
  }

  Future<void> _applyRemote(FileEntry remote) async {
    final row = await _store.file(remote.path);
    if (row != null && (row.unsynced || (await _store.outboxFor(remote.path)).isNotEmpty)) return;
    if (row != null && row.baseRev == remote.rev && row.entry == remote) return;
    await _store.saveFile(
      OfflineFile.fromServer(remote, localHash: row?.localHash == remote.hash ? row?.localHash : null),
    );
  }

  Future<void> _forgetSynced(String path) async {
    for (final row in await _store.tree(path)) {
      if (!row.unsynced && (await _store.outboxFor(row.path)).isEmpty) await _store.deleteFile(row.path);
    }
  }

  Future<bool> _moveSynced(String from, String to, List<OfflinePin> pins) async {
    final rows = await _store.tree(from);
    if (rows.isEmpty) return false;
    if (rows.any((row) => row.unsynced)) return true;
    if (!pins.mirrors(to)) {
      await _store.deleteTree(from);
      return true;
    }
    await _moveRows(from, to, pending: false);
    return true;
  }

  Future<void> _moveRows(String from, String to, {required bool pending}) async {
    for (final row in await _store.tree(from)) {
      final path = row.path == from ? to : RemotePath.join(to, RemotePath.relativeTo(row.path, from)!);
      await _store.deleteFile(row.path);
      await _store.saveFile(
        row.copyWith(
          entry: row.entry.copyWith(path: path, name: RemotePath.name(path)),
          state: pending && row.path == from && row.state == OfflineFileState.synced
              ? OfflineFileState.pending
              : row.state,
        ),
      );
    }
  }

  Future<void> _populate(OfflinePin pin) async {
    final root = await _statOrNull(pin.path);
    final seen = <String>{};
    if (root != null) {
      await _lock.run(() => _applyRemote(root));
      seen.add(root.path);
      if (root.isDir) seen.addAll(await _listInto(root.path));
    }
    await _lock.run(() async {
      if (!(await _store.pins()).contains(pin)) return;
      await _store.batch(() async {
        for (final row in await _store.tree(pin.path)) {
          if (!seen.contains(row.path) && !row.unsynced && (await _store.outboxFor(row.path)).isEmpty) {
            await _store.deleteFile(row.path);
          }
        }
        await _store.savePin(pin.copyWith(populated: true));
      });
    });
  }

  Future<Set<String>> _listInto(String folder) async {
    final seen = <String>{};
    final pending = [folder];
    while (pending.isNotEmpty) {
      final listing = await _api.list(pending.removeLast());
      await _lock.run(
        () => _store.batch(() async {
          for (final entry in listing.entries) {
            await _applyRemote(entry);
          }
        }),
      );
      for (final entry in listing.entries) {
        seen.add(entry.path);
        if (entry.isDir && entry.mount == null) pending.add(entry.path);
      }
    }
    return seen;
  }

  FileEntry _newEntry(String path, {required bool isDir}) => FileEntry(
    path: path,
    name: RemotePath.name(path),
    isDir: isDir,
    mtime: _clock(),
    mime: isDir ? "" : _mimeOf(path),
  );

  static String _mimeOf(String path) {
    if (RemotePath.extension(path).toLowerCase() == noteExtension) return markdownMime;
    return lookupMimeType(path) ?? "application/octet-stream";
  }

  static OutboxOp _relocated(OutboxOp op, String from, String to) {
    String moved(String path) => path == from ? to : RemotePath.join(to, RemotePath.relativeTo(path, from)!);
    bool affected(String path) => path == from || RemotePath.isWithin(path, from);
    return switch (op) {
      PutOp(:final path, :final hash, :final size) when affected(path) => OutboxOp.put(
        path: moved(path),
        hash: hash,
        size: size,
      ),
      MoveOp(from: final source, to: final target) => OutboxOp.move(
        from: affected(source) ? moved(source) : source,
        to: affected(target) ? moved(target) : target,
      ),
      DeleteOp(:final path, :final baseRev) when affected(path) => OutboxOp.delete(path: moved(path), baseRev: baseRev),
      final op => op,
    };
  }

  static List<String> _pathsOf(OutboxOp op) => switch (op) {
    MoveOp(:final from, :final to) => [from, to],
    final op => [op.path],
  };

  static bool _touches(OutboxOp op, String path) => _pathsOf(op).any(
    (candidate) => candidate == path || RemotePath.isWithin(candidate, path) || RemotePath.isWithin(path, candidate),
  );
}
