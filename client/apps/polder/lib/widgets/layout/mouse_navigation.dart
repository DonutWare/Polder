import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/app/navigation_history_provider.dart";

class MouseNavigation extends ConsumerWidget {
  const MouseNavigation({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(navigationHistoryProvider.notifier);
    if (kIsWeb) return child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (event.kind != PointerDeviceKind.mouse) return;
        if (event.buttons & kBackMouseButton != 0) {
          unawaited(history.back());
        } else if (event.buttons & kForwardMouseButton != 0) {
          history.forward();
        }
      },
      child: child,
    );
  }
}
