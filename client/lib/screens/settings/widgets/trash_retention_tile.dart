import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/trash.dart";
import "package:nomad/providers/trash/trash_provider.dart";
import "package:nomad/util/action_feedback.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/nav_group.dart";
import "package:nomad/widgets/shared/retention_picker_dialog.dart";

class TrashRetentionTile extends ConsumerWidget {
  const TrashRetentionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retention = ref.watch(trashRetentionProvider).value;
    return NavEntry(
      icon: IconsaxPlusLinear.trash,
      title: context.localized.trashRetention,
      subtitle: retention == null ? null : _describe(context, retention),
      trailing: retention?.locked ?? false ? const Icon(IconsaxPlusLinear.lock_1, size: 18) : null,
      onTap: retention == null || retention.locked ? null : () => _choose(context, ref, retention),
    );
  }

  String _describe(BuildContext context, TrashRetention retention) {
    final duration = context.retentionDuration(retention.days);
    return switch (retention.source) {
      RetentionSource.serverDefault => context.localized.trashRetentionServerDefault(duration),
      RetentionSource.user => duration,
      RetentionSource.server || RetentionSource.admin => "$duration · ${context.localized.trashRetentionSetByAdmin}",
    };
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, TrashRetention retention) async {
    final choice = await showRetentionPicker(
      context,
      title: context.localized.trashRetention,
      selected: retention.userDays,
      followDefaultLabel: context.localized.trashRetentionServerDefault(
        context.retentionDuration(retention.defaultDays),
      ),
    );
    if (choice != null && context.mounted) {
      await context.runWithFeedback(ref.read(trashRetentionProvider.notifier).choose(choice.days));
    }
  }
}
