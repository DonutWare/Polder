import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/retention_picker_dialog.dart";

class TrashRetentionGroup extends ConsumerWidget {
  const TrashRetentionGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(serverSettingsProvider).value;
    final notifier = ref.read(serverSettingsProvider.notifier);
    final localized = context.localized;
    if (settings == null) return const SizedBox.shrink();
    return NavGroup(
      title: localized.navTrash,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.trash,
          title: localized.serverTrashRetention,
          subtitle: localized.serverTrashRetentionHint(context.retentionDuration(settings.trashRetentionDays)),
          onTap: () => _chooseDays(context, notifier, settings),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.enforceTrashRetention),
          subtitle: Text(localized.enforceTrashRetentionHint),
          value: settings.trashRetentionEnforced,
          onChanged: (enforced) => context.runWithFeedback(notifier.setTrashRetentionEnforced(enforced)),
        ),
      ],
    );
  }

  Future<void> _chooseDays(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final choice = await showRetentionPicker(
      context,
      title: context.localized.serverTrashRetention,
      selected: settings.trashRetentionDays,
    );
    final days = choice?.days;
    if (days != null && context.mounted) await context.runWithFeedback(notifier.setTrashRetentionDays(days));
  }
}
