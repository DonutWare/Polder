import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/providers/sync/sync_scheduler_provider.dart";

class SyncBackgroundActivator extends ConsumerWidget {
  const SyncBackgroundActivator({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncSchedulerProvider);
    return child;
  }
}
