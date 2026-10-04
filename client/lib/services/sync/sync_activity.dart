import "dart:async";
import "dart:io";

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/sync/sync_ignore_rules.dart";
import "package:nomad/services/sync/sync_paths.dart";

enum LocalSyncPhase { waiting, preparing, uploading }

class LocalSyncItem {
  const LocalSyncItem({
    required this.rootId,
    required this.relativePath,
    required this.remotePath,
    required this.phase,
    this.noticedAt,
    this.bytes = 0,
    this.total,
    this.rate = 0,
  });

  final String rootId;
  final String relativePath;
  final String remotePath;
  final LocalSyncPhase phase;

  /// When the folder watcher last saw it change; null for files a sync run found by itself.
  final DateTime? noticedAt;
  final int bytes;
  final int? total;
  final int rate;

  double? get progress {
    final expected = total;
    return expected == null || expected <= 0 || phase == LocalSyncPhase.waiting
        ? null
        : (bytes / expected).clamp(0.0, 1.0);
  }

  String get group {
    final segments = relativePath.split("/");
    return segments.length > 1 ? "$rootId:${segments.first}" : "$rootId:";
  }

  String get groupRemotePath {
    final depth = relativePath.split("/").length - 1;
    var path = remotePath;
    for (var i = 0; i < (depth == 0 ? 1 : depth); i++) {
      final index = path.lastIndexOf("/");
      path = index <= 0 ? "/" : path.substring(0, index);
    }
    return path;
  }

  LocalSyncItem copyWith({LocalSyncPhase? phase, int? bytes, int? total, int? rate, DateTime? noticedAt}) =>
      LocalSyncItem(
        rootId: rootId,
        relativePath: relativePath,
        remotePath: remotePath,
        phase: phase ?? this.phase,
        noticedAt: noticedAt ?? this.noticedAt,
        bytes: bytes ?? this.bytes,
        total: total ?? this.total,
        rate: rate ?? this.rate,
      );
}

enum CancelReason { removed, changed, stopped, paused }

class SyncCancelledException implements Exception {
  const SyncCancelledException(this.path, [this.reason = CancelReason.removed]);

  final String path;
  final CancelReason reason;

  @override
  String toString() => "SyncCancelledException($path, ${reason.name})";
}

class CancelToken {
  CancelToken();

  CancelToken.cancelled(CancelReason reason) {
    cancel(reason);
  }

  final _cancelled = Completer<void>();
  CancelReason? _reason;

  bool get isCancelled => _cancelled.isCompleted;

  CancelReason? get reason => _reason;

  Future<void> get whenCancelled => _cancelled.future;

  void cancel([CancelReason reason = CancelReason.stopped]) {
    if (_cancelled.isCompleted) return;
    _reason = reason;
    _cancelled.complete();
  }

  void throwIfCancelled(String path) {
    if (isCancelled) throw SyncCancelledException(path, _reason!);
  }
}

extension CancellableFuture<T> on Future<T> {
  Future<T> unlessCancelled(CancelToken? cancel, String path) => cancel == null
      ? this
      : Future.any([this, cancel.whenCancelled.then<T>((_) => throw SyncCancelledException(path, cancel.reason!))]);
}

extension CancellableStream<T> on Stream<T> {
  Stream<T> unlessCancelled(CancelToken? cancel, String path) async* {
    await for (final event in this) {
      cancel?.throwIfCancelled(path);
      yield event;
    }
  }
}

class SyncActivity {
  SyncActivity({this._clock = DateTime.now});

  static const notifyInterval = Duration(milliseconds: 150);
  static const _ownWriteWindow = Duration(seconds: 5);
  static const _maxListedPerFolder = 2000;
  static const _rateSmoothing = 0.3;

  final DateTime Function() _clock;
  final _changes = StreamController<Map<String, LocalSyncItem>>.broadcast();
  final Map<String, LocalSyncItem> _items = {};
  final Map<String, CancelToken> _tokens = {};
  final Map<String, DateTime> _ownWrites = {};
  final Map<String, DateTime> _lastProgress = {};
  final Map<String, CancelToken> _runs = {};
  final Map<String, int> _completed = {};
  Timer? _pendingNotify;

  Map<String, LocalSyncItem> get items => Map.unmodifiable(_items);

  Map<String, int> get completed => Map.unmodifiable(_completed);

  Stream<Map<String, LocalSyncItem>> get changes => _changes.stream;

  static String _key(String rootId, String relativePath) => "$rootId:$relativePath";

  Future<void> observe(SyncRoot root, String absolutePath) async {
    final paths = SyncPaths(root);
    final relativePath = paths.relativePath(absolutePath);
    if (relativePath.startsWith("..") || relativePath == ".") return;
    if (SyncIgnoreRules.isIgnored(relativePath, mode: root.mode) || _isOwnWrite(root.id, relativePath)) return;
    switch (await FileSystemEntity.type(absolutePath, followLinks: false)) {
      case FileSystemEntityType.file:
        _notice(root, relativePath);
      case FileSystemEntityType.directory:
        await _noticeFolder(root, relativePath);
      case FileSystemEntityType.notFound:
        vanished(root.id, relativePath);
      default:
    }
  }

  Future<void> _noticeFolder(SyncRoot root, String relativePath) async {
    var listed = 0;
    final paths = SyncPaths(root);
    try {
      await for (final entity in paths.directory(relativePath).list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final child = paths.relativePath(entity.path);
        if (SyncIgnoreRules.isIgnored(child, mode: root.mode) || _isOwnWrite(root.id, child)) continue;
        _notice(root, child, notify: false);
        if (++listed >= _maxListedPerFolder) break;
      }
    } on FileSystemException {
      return _notify();
    }
    _notify();
  }

  void _notice(SyncRoot root, String relativePath, {bool notify = true}) {
    final key = _key(root.id, relativePath);
    final existing = _items[key];
    if (existing != null && existing.phase != LocalSyncPhase.waiting) {
      _tokens.remove(key)?.cancel(CancelReason.changed);
    }
    _items[key] = LocalSyncItem(
      rootId: root.id,
      relativePath: relativePath,
      remotePath: SyncPaths(root).remotePath(relativePath),
      phase: LocalSyncPhase.waiting,
      noticedAt: _clock(),
    );
    if (notify) _notify();
  }

  void enqueue(SyncRoot root, Iterable<String> relativePaths) {
    var added = false;
    for (final relativePath in relativePaths) {
      final key = _key(root.id, relativePath);
      if (_items.containsKey(key)) continue;
      _items[key] = LocalSyncItem(
        rootId: root.id,
        relativePath: relativePath,
        remotePath: SyncPaths(root).remotePath(relativePath),
        phase: LocalSyncPhase.waiting,
      );
      added = true;
    }
    if (added) _notify();
  }

  void vanished(String rootId, String relativePath) {
    final prefix = _key(rootId, "$relativePath/");
    final exact = _key(rootId, relativePath);
    bool matches(String key) => key == exact || key.startsWith(prefix);
    for (final key in _tokens.keys.where(matches).toList()) {
      _tokens.remove(key)!.cancel(CancelReason.removed);
    }
    final before = _items.length;
    _items.removeWhere((key, _) => matches(key));
    if (_items.length != before) {
      _forgetFinishedGroups();
      _notify();
    }
  }

  CancelToken startRun(String rootId) => _runs[rootId] = CancelToken();

  void endRun(String rootId, CancelToken run) {
    if (identical(_runs[rootId], run)) _runs.remove(rootId);
  }

  void cancelRoot(String rootId, CancelReason reason) {
    _runs[rootId]?.cancel(reason);
    final prefix = _key(rootId, "");
    for (final key in _tokens.keys.where((key) => key.startsWith(prefix)).toList()) {
      _tokens.remove(key)!.cancel(reason);
    }
    if (reason == CancelReason.paused) {
      final now = _clock();
      _items.updateAll(
        (key, item) => key.startsWith(prefix)
            ? LocalSyncItem(
                rootId: item.rootId,
                relativePath: item.relativePath,
                remotePath: item.remotePath,
                phase: LocalSyncPhase.waiting,
                noticedAt: now,
              )
            : item,
      );
    } else {
      _items.removeWhere((key, _) => key.startsWith(prefix));
      _forgetFinishedGroups();
    }
    _notify();
  }

  void cancelAll(CancelReason reason) {
    for (final rootId in {..._runs.keys, for (final item in _items.values) item.rootId}) {
      cancelRoot(rootId, reason);
    }
  }

  CancelToken begin(SyncRoot root, String relativePath, LocalSyncPhase phase, {int? total}) {
    final run = _runs[root.id];
    if (run != null && run.isCancelled) return CancelToken.cancelled(run.reason!);
    final key = _key(root.id, relativePath);
    final current = _items[key];
    _items[key] =
        (current ??
                LocalSyncItem(
                  rootId: root.id,
                  relativePath: relativePath,
                  remotePath: SyncPaths(root).remotePath(relativePath),
                  phase: phase,
                ))
            .copyWith(phase: phase, bytes: 0, total: total, rate: 0);
    _lastProgress.remove(key);
    _notify();
    final token = _tokens[key];
    return token != null && !token.isCancelled ? token : _tokens[key] = CancelToken();
  }

  void progress(String rootId, String relativePath, int bytes) {
    final key = _key(rootId, relativePath);
    final current = _items[key];
    if (current == null) return;
    final now = _clock();
    final last = _lastProgress[key];
    var rate = current.rate;
    if (last != null) {
      final seconds = now.difference(last).inMicroseconds / Duration.microsecondsPerSecond;
      if (seconds > 0) {
        final instant = (bytes - current.bytes) / seconds;
        rate = (rate == 0 ? instant : _rateSmoothing * instant + (1 - _rateSmoothing) * rate).round();
      }
    }
    _lastProgress[key] = now;
    _items[key] = current.copyWith(bytes: bytes, rate: rate < 0 ? 0 : rate);
    _notify(throttled: true);
  }

  void done(String rootId, String relativePath) {
    final key = _key(rootId, relativePath);
    _tokens.remove(key);
    _lastProgress.remove(key);
    final finished = _items.remove(key);
    if (finished == null) return;
    _completed.update(finished.group, (count) => count + 1, ifAbsent: () => 1);
    _forgetFinishedGroups();
    _notify();
  }

  void _forgetFinishedGroups() {
    final active = {for (final item in _items.values) item.group};
    _completed.removeWhere((group, _) => !active.contains(group));
  }

  void expectWrite(String rootId, String relativePath) => _ownWrites[_key(rootId, relativePath)] = _clock();

  bool _isOwnWrite(String rootId, String relativePath) {
    final now = _clock();
    _ownWrites.removeWhere((_, at) => now.difference(at) > _ownWriteWindow);
    return _ownWrites.containsKey(_key(rootId, relativePath));
  }

  void settle(String rootId, DateTime runStartedAt) {
    final settled = [
      for (final MapEntry(:key, value: item) in _items.entries)
        if (item.rootId == rootId && !(item.noticedAt?.isAfter(runStartedAt) ?? false)) key,
    ];
    for (final key in settled) {
      _items.remove(key);
      _tokens.remove(key);
      _lastProgress.remove(key);
    }
    if (settled.isNotEmpty) {
      _forgetFinishedGroups();
      _notify();
    }
  }

  void _notify({bool throttled = false}) {
    if (_changes.isClosed) return;
    if (!throttled) {
      _pendingNotify?.cancel();
      _pendingNotify = null;
      _changes.add(items);
      return;
    }
    _pendingNotify ??= Timer(notifyInterval, () {
      _pendingNotify = null;
      if (!_changes.isClosed) _changes.add(items);
    });
  }

  void dispose() {
    _pendingNotify?.cancel();
    for (final token in [..._tokens.values, ..._runs.values]) {
      token.cancel();
    }
    _changes.close();
  }
}
