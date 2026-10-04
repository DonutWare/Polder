import "dart:async";

class SyncScheduler {
  SyncScheduler({
    required this.onTrigger,
    this.interval = const Duration(minutes: 5),
    this.debounce = const Duration(seconds: 1),
  });

  final void Function() onTrigger;
  final Duration interval;
  final Duration debounce;

  Timer? _periodic;
  Timer? _debounced;
  final List<StreamSubscription<Object?>> _watchers = [];

  void start(Iterable<Stream<Object?>> folderEvents) {
    stop();
    _periodic = Timer.periodic(interval, (_) => onTrigger());
    _watchers.addAll(folderEvents.map((events) => events.listen((_) => requestRun())));
    // Deferred so the first run never happens while the owning provider is still building.
    _debounced = Timer(Duration.zero, onTrigger);
  }

  void stop() {
    _periodic?.cancel();
    _debounced?.cancel();
    for (final watcher in _watchers) {
      unawaited(watcher.cancel());
    }
    _watchers.clear();
  }

  /// Debounced run, e.g. after the app itself changed files on the server.
  void requestRun() {
    _debounced?.cancel();
    _debounced = Timer(debounce, onTrigger);
  }
}
