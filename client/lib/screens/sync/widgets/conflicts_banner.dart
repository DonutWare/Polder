import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/notice_tile.dart";

class ConflictsBanner extends ConsumerWidget {
  const ConflictsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(conflictQueueProvider.select((queue) => queue.conflicts.length));
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: NoticeTile(
        icon: IconsaxPlusLinear.warning_2,
        color: AppColors.of(context).warning,
        text: context.localized.conflictsWaiting(count),
        action: FilledButton.tonal(
          onPressed: () => context.push(AppRoutes.conflicts),
          child: Text(context.localized.resolve),
        ),
      ),
    );
  }
}
