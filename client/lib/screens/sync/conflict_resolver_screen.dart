import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/sync/conflict_queue_provider.dart";
import "package:nomad/screens/sync/widgets/apply_to_all_checkbox.dart";
import "package:nomad/screens/sync/widgets/conflict_tile.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/layout/adaptive.dart";
import "package:nomad/widgets/layout/app_page.dart";
import "package:nomad/widgets/shared/message_view.dart";
import "package:nomad/widgets/shared/nav_group.dart";

class ConflictResolverScreen extends ConsumerWidget {
  const ConflictResolverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(conflictQueueProvider.select((queue) => queue.conflicts));
    return AppPage(
      title: Text(context.localized.conflicts),
      body: conflicts.isEmpty
          ? MessageView(
              icon: IconsaxPlusLinear.tick_circle,
              color: AppColors.of(context).success,
              message: context.localized.noConflicts,
            )
          : ReadableWidth(
              maxWidth: 840,
              builder: (context, inset) => ListView(
                padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  NavGroup(
                    title: context.localized.conflictsWaiting(conflicts.length),
                    children: [for (final conflict in conflicts) ConflictTile(conflict: conflict)],
                  ),
                  const ApplyToAllCheckbox(),
                ],
              ),
            ),
    );
  }
}
