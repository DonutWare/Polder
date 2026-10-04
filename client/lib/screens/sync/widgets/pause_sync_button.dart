import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/sync/sync_paused_provider.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/util/localization_helper.dart";

class PauseSyncButton extends ConsumerWidget {
  const PauseSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(syncPlatformProvider).supportsSync) return const SizedBox.shrink();
    final paused = ref.watch(syncPausedProvider).value ?? false;
    final notifier = ref.read(syncPausedProvider.notifier);
    return IconButton(
      tooltip: paused ? context.localized.resumeSync : context.localized.pauseSync,
      icon: Icon(paused ? IconsaxPlusLinear.play : IconsaxPlusLinear.pause),
      onPressed: paused ? notifier.resume : notifier.pause,
    );
  }
}
