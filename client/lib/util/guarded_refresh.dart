import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

mixin GuardedRefresh<T> on AsyncNotifier<T> {
  var _generation = 0;

  Future<T?> refreshWith(Future<T> Function() fetch, {bool keepOnError = false}) async {
    final generation = ++_generation;
    final result = await AsyncValue.guard(fetch);
    if (!ref.mounted || generation != _generation || (keepOnError && result.hasError)) return null;
    state = result;
    return result.value;
  }

  void settle(T value) {
    _generation++;
    state = AsyncData(value);
  }

  Future<T> localFirst({required Future<T?> Function() local, required Future<T> Function() remote}) async {
    _generation++;
    final cached = await local();
    if (cached == null) return remote();
    unawaited(Future(() => refreshWith(remote, keepOnError: true)));
    return cached;
  }
}
