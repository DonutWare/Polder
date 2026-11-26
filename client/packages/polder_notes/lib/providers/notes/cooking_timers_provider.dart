import "dart:async";

import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

final cookingTimersProvider = NotifierProvider.autoDispose<CookingTimers, List<CookingTimer>>(CookingTimers.new);

class CookingTimer {
  const CookingTimer({required this.key, required this.label, required this.endsAt});

  final String key;
  final String label;
  final DateTime endsAt;

  Duration remainingAt(DateTime now) => endsAt.isAfter(now) ? endsAt.difference(now) : Duration.zero;

  bool finishedAt(DateTime now) => !endsAt.isAfter(now);
}

class CookingTimers extends Notifier<List<CookingTimer>> {
  static const _tick = Duration(seconds: 1);

  Timer? _ticker;
  final _announced = <String>{};

  @override
  List<CookingTimer> build() {
    ref.onDispose(() => _ticker?.cancel());
    return const [];
  }

  CookingTimer? timerFor(String key) => state.where((timer) => timer.key == key).firstOrNull;

  void start(String key, String label, Duration duration) {
    _announced.remove(key);
    state = [
      ...state.where((timer) => timer.key != key),
      CookingTimer(key: key, label: label, endsAt: DateTime.now().add(duration)),
    ];
    _ticker ??= Timer.periodic(_tick, (_) => _onTick());
  }

  void stop(String key) {
    _announced.remove(key);
    state = state.where((timer) => timer.key != key).toList();
    if (state.isEmpty) _stopTicking();
  }

  void _onTick() {
    final now = DateTime.now();
    for (final timer in state) {
      if (timer.finishedAt(now) && _announced.add(timer.key)) _announce();
    }
    state = [...state];
  }

  void _announce() {
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.alert));
  }

  void _stopTicking() {
    _ticker?.cancel();
    _ticker = null;
  }
}
