import "package:flutter/widgets.dart";

class SlideshowController extends ChangeNotifier {
  SlideshowController({required TickerProvider vsync, required this.onAdvance})
    : _countdown = AnimationController(vsync: vsync, duration: intervals[1]) {
    _countdown.addStatusListener(_onCountdownStatus);
  }

  static const intervals = [Duration(seconds: 3), Duration(seconds: 5), Duration(seconds: 10), Duration(seconds: 15)];

  final VoidCallback onAdvance;
  final AnimationController _countdown;
  bool _running = false;
  bool _showingVideo = false;

  bool get running => _running;

  bool get countingDown => _running && !_showingVideo;

  Animation<double> get progress => _countdown;

  Duration get interval => _countdown.duration!;

  set interval(Duration value) {
    _countdown.duration = value;
    _restartCountdown();
    notifyListeners();
  }

  void toggle() => _running ? stop() : start();

  void start() {
    _running = true;
    _restartCountdown();
    notifyListeners();
  }

  void stop() {
    _running = false;
    _countdown
      ..stop()
      ..value = 0;
    notifyListeners();
  }

  void showItem({required bool isVideo}) {
    _showingVideo = isVideo;
    _restartCountdown();
    notifyListeners();
  }

  void videoCompleted() {
    if (_running && _showingVideo) onAdvance();
  }

  void _restartCountdown() {
    _countdown.stop();
    _countdown.value = 0;
    if (_running && !_showingVideo) _countdown.forward();
  }

  void _onCountdownStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _running) onAdvance();
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }
}
