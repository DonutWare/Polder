import "dart:collection";

class ThroughputMeter {
  ThroughputMeter({this.window = const Duration(seconds: 5), this._clock = DateTime.now});

  static const _minimumSpan = Duration(seconds: 1);

  final Duration window;
  final DateTime Function() _clock;
  final Queue<(DateTime, int)> _samples = Queue();
  int _bytes = 0;
  DateTime? _since;

  void add(int bytes) {
    if (bytes <= 0) return;
    final now = _clock();
    _prune(now);
    _since ??= now;
    _samples.add((now, bytes));
    _bytes += bytes;
  }

  int get rate {
    final now = _clock();
    _prune(now);
    final since = _since;
    if (since == null) return 0;
    var span = now.difference(since);
    if (span > window) span = window;
    if (span < _minimumSpan) span = _minimumSpan;
    return (_bytes * Duration.microsecondsPerSecond / span.inMicroseconds).round();
  }

  void _prune(DateTime now) {
    final cutoff = now.subtract(window);
    while (_samples.isNotEmpty && _samples.first.$1.isBefore(cutoff)) {
      _bytes -= _samples.removeFirst().$2;
    }
    if (_samples.isEmpty) _since = null;
  }
}
