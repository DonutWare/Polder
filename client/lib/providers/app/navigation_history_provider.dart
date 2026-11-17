import "dart:async";

import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/browser_history.dart";

@immutable
class NavigationHistory {
  const NavigationHistory({this.locations = const [], this.index = -1});

  static const maxLocations = 100;

  final List<String> locations;
  final int index;

  String? get current => index < 0 ? null : locations[index];

  String? get previous => index > 0 ? locations[index - 1] : null;

  String? get next => index + 1 < locations.length ? locations[index + 1] : null;

  NavigationHistory moveTo(int target) =>
      target < 0 || target >= locations.length ? this : NavigationHistory(locations: locations, index: target);

  NavigationHistory visit(String location, {bool followAdjacent = false, bool replace = false}) {
    if (location == current) return this;
    if (location == AppRoutes.login) return const NavigationHistory();
    if (followAdjacent && location == previous) return moveTo(index - 1);
    if (followAdjacent && location == next) return moveTo(index + 1);
    final visited = [...locations.take(replace ? index : index + 1), location];
    final kept = visited.length > maxLocations ? visited.sublist(visited.length - maxLocations) : visited;
    return NavigationHistory(locations: kept, index: kept.length - 1);
  }
}

final navigationHistoryProvider = NotifierProvider<NavigationHistoryNotifier, NavigationHistory>(
  NavigationHistoryNotifier.new,
);

class NavigationHistoryNotifier extends Notifier<NavigationHistory> {
  GoRouter get _router => ref.read(routerProvider);
  var _replacing = false;

  @override
  NavigationHistory build() {
    final delegate = ref.watch(routerProvider).routerDelegate;
    void record() {
      final configuration = delegate.currentConfiguration;
      final replace = _replacing;
      scheduleMicrotask(() {
        if (ref.mounted) _record(configuration, replace: replace);
      });
    }

    delegate.addListener(record);
    ref.onDispose(() => delegate.removeListener(record));
    final configuration = delegate.currentConfiguration;
    return configuration.isEmpty
        ? const NavigationHistory()
        : const NavigationHistory().visit(_location(configuration));
  }

  void _record(RouteMatchList configuration, {bool replace = false}) {
    if (configuration.isEmpty || configuration.last is ImperativeRouteMatch) return;
    state = state.visit(_location(configuration), followAdjacent: kIsWeb && !replace, replace: replace);
  }

  static String _location(RouteMatchList configuration) => configuration.uri.toString();

  void replace(String location) {
    _replacing = true;
    try {
      _router.go(location);
    } finally {
      _replacing = false;
    }
  }

  Future<void> back() async {
    if (_router.canPop()) {
      await _router.routerDelegate.popRoute();
    } else if (!goBackInBrowser()) {
      _go(state.index - 1);
    }
  }

  void retreat() {
    if (!goBackInBrowser()) _go(state.index - 1);
  }

  void forward() {
    if (!goForwardInBrowser()) _go(state.index + 1);
  }

  void _go(int target) {
    final moved = state.moveTo(target);
    if (identical(moved, state)) return;
    state = moved;
    _router.go(moved.current!);
  }
}
