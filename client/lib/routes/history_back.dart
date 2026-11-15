import "package:flutter/widgets.dart";

import "package:go_router/go_router.dart";

class HistoryBack extends InheritedWidget {
  const HistoryBack({
    required this.current,
    required this.previous,
    required this.onBack,
    required this.onReplace,
    required super.child,
    super.key,
  });

  final String? current;
  final String? previous;
  final VoidCallback onBack;
  final ValueChanged<String> onReplace;

  static HistoryBack? _of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<HistoryBack>();

  static String? previousFrom(BuildContext context, {String? location}) {
    final scope = _of(context);
    if (scope == null || scope.previous == null) return null;
    final at = location ?? GoRouterState.of(context).uri.toString();
    return scope.current == at ? scope.previous : null;
  }

  static void goBack(BuildContext context) => context.getInheritedWidgetOfExactType<HistoryBack>()?.onBack();

  static void replaceWith(BuildContext context, String location) {
    final scope = context.getInheritedWidgetOfExactType<HistoryBack>();
    scope == null ? GoRouter.of(context).go(location) : scope.onReplace(location);
  }

  @override
  bool updateShouldNotify(HistoryBack oldWidget) =>
      current != oldWidget.current ||
      previous != oldWidget.previous ||
      onBack != oldWidget.onBack ||
      onReplace != oldWidget.onReplace;
}
