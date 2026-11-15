import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/routes/history_back.dart";

class NavigationHistoryScope extends ConsumerWidget {
  const NavigationHistoryScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(navigationHistoryProvider);
    final notifier = ref.read(navigationHistoryProvider.notifier);
    return HistoryBack(
      current: history.current,
      previous: history.previous,
      onBack: notifier.retreat,
      onReplace: notifier.replace,
      child: child,
    );
  }
}
