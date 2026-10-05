import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/util/localization_helper.dart";

class SyncNowButton extends ConsumerWidget {
  const SyncNowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncing = ref.watch(syncStatusProvider.select((status) => status.isSyncing));
    return IconButton(
      tooltip: context.localized.syncNow,
      icon: syncing
          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(IconsaxPlusLinear.refresh_2),
      onPressed: syncing ? null : ref.read(syncStatusProvider.notifier).syncNow,
    );
  }
}
