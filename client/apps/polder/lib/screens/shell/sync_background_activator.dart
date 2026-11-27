import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder_drive/providers/realtime/directory_refresher_provider.dart";
import "package:polder_drive/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/features/feature_modes.dart";

class SyncBackgroundActivator extends ConsumerWidget {
  const SyncBackgroundActivator({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(resolvedFeatureModesProvider.select((modes) => modes.isBuiltIn(PolderFeature.drive)))) {
      ref.watch(syncSchedulerProvider);
    }
    ref.watch(directoryRefresherProvider);
    return child;
  }
}
