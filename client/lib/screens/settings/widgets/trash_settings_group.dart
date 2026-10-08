import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/trash.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/retention_picker_dialog.dart";

class TrashSettingsGroup extends ConsumerWidget {
  const TrashSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retention = ref.watch(trashRetentionProvider).value;
    final localized = context.localized;
    if (retention == null) return const SizedBox.shrink();
    final changeable = retention.changeable;
    return NavGroup(
      title: localized.navTrash,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.trashKeep),
          subtitle: Text(changeable ? localized.trashKeepHint : localized.trashTurnedOffByAdmin),
          value: retention.enabled,
          onChanged: changeable ? (enabled) => _setEnabled(context, ref, retention, enabled) : null,
        ),
        if (retention.enabled)
          NavEntry(
            icon: IconsaxPlusLinear.trash,
            title: localized.trashRetention,
            subtitle: retention.user.days == null
                ? localized.trashRetentionServerDefault(context.retentionDuration(retention.days))
                : context.retentionDuration(retention.days),
            onTap: () => _chooseDays(context, ref, retention),
          ),
      ],
    );
  }

  Future<void> _setEnabled(BuildContext context, WidgetRef ref, TrashRetention retention, bool enabled) async {
    if (!enabled) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.localized.trashTurnOffTitle,
        message: context.localized.trashTurnOffMessage,
        confirmLabel: context.localized.turnOff,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    await _save(context, ref, retention.user.copyWith(enabled: enabled));
  }

  Future<void> _chooseDays(BuildContext context, WidgetRef ref, TrashRetention retention) async {
    final choice = await showRetentionPicker(
      context,
      title: context.localized.trashRetention,
      selected: retention.user.days,
      followDefaultLabel: context.localized.trashRetentionServerDefault(
        context.retentionDuration(retention.serverDays),
      ),
      maximum: retention.serverDays,
    );
    if (choice != null && context.mounted) await _save(context, ref, retention.user.copyWith(days: choice.days));
  }

  Future<void> _save(BuildContext context, WidgetRef ref, TrashPreferences preferences) =>
      context.runWithFeedback(ref.read(trashRetentionProvider.notifier).choose(preferences));
}
