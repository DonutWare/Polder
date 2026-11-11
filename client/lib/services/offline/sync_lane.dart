import "dart:async";

import "package:polder/services/offline/outbox_errors.dart";

typedef SyncWork = Future<DateTime?> Function();

class SyncLane {
  SyncLane(
    this._work, {
    this.debounce = const Duration(milliseconds: 300),
    this.watchdog,
    Future<bool> Function()? canRun,
    DateTime Function()? clock,
  }) : _canRun = canRun ?? _always,
       _clock = clock ?? DateTime.now;

  final SyncWork _work;
  final Duration debounce;
  final Duration? watchdog;
  final Future<bool> Function() _canRun;
  final DateTime Function() _clock;
  Timer? _debounceTimer;
  Timer? _retryTimer;
  Future<void>? _running;
  var _again = false;
  var _failures = 0;
  var _disposed = false;
  Object? _lastError;

  static Future<bool> _always() async => true;

  bool get running => _running != null;

  Object? get lastError => _lastError;

  void kick({Duration? delay}) {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay ?? debounce, () => unawaited(run()));
  }

  Future<void> run() {
    if (_disposed) return Future.value();
    if (_running case final running?) {
      _again = true;
      return running;
    }
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    final running = _runOnce().whenComplete(_finish);
    _running = running;
    return running;
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
  }

  Future<void> _runOnce() async {
    if (!await _canRun()) return;
    try {
      final work = _work();
      final retryAt = await (watchdog == null ? work : work.timeout(watchdog!));
      _failures = 0;
      _lastError = null;
      _retryAt(retryAt);
    } on Object catch (error) {
      _failures++;
      _lastError = error;
      _retryAt(_clock().add(OutboxErrors.retryDelay(_failures)));
    }
  }

  void _finish() {
    _running = null;
    if (_again && !_disposed) {
      _again = false;
      kick();
    }
  }

  void _retryAt(DateTime? at) {
    if (at == null || _disposed) return;
    final delay = at.difference(_clock());
    _retryTimer?.cancel();
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () => unawaited(run()));
  }
}
