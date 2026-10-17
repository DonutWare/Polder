import "package:flutter_riverpod/flutter_riverpod.dart";

mixin GuardedRefresh<T> on AsyncNotifier<T> {
  Future<T?> refreshWith(Future<T> Function() fetch, {bool keepOnError = false}) async {
    final result = await AsyncValue.guard(fetch);
    if (!ref.mounted || (keepOnError && result.hasError)) return null;
    state = result;
    return result.value;
  }
}
