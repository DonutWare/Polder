import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_version.dart";
import "package:polder/providers/versions/file_versions_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/count_input_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/retention_picker_dialog.dart";

class VersionSettingsGroup extends ConsumerWidget {
  const VersionSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retention = ref.watch(versionSettingsProvider).value;
    final localized = context.localized;
    if (retention == null) return const SizedBox.shrink();
    final changeable = retention.changeable;
    final lock = changeable ? null : const Icon(IconsaxPlusLinear.lock_1, size: 18);
    final setByAdmin = changeable ? "" : " · ${localized.trashRetentionSetByAdmin}";
    return NavGroup(
      title: localized.versionHistory,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.versionsKeep),
          subtitle: Text(localized.versionsKeepHint + setByAdmin),
          value: retention.enabled,
          onChanged: changeable ? (enabled) => _setEnabled(context, ref, retention, enabled) : null,
        ),
        if (retention.enabled) ...[
          NavEntry(
            icon: IconsaxPlusLinear.layer,
            title: localized.versionsMaxPerFile,
            subtitle: localized.versionsPerFile(retention.maxPerFile),
            trailing: lock,
            onTap: changeable ? () => _choosePerFile(context, ref, retention) : null,
          ),
          NavEntry(
            icon: IconsaxPlusLinear.clock,
            title: localized.versionsMaxAge,
            subtitle: context.retentionDuration(retention.maxAgeDays),
            trailing: lock,
            onTap: changeable ? () => _chooseAge(context, ref, retention) : null,
          ),
        ],
      ],
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    required bool? enabled,
    required int? maxAgeDays,
    required int? maxPerFile,
  }) => context.runWithFeedback(
    ref.read(versionSettingsProvider.notifier).choose(enabled: enabled, maxAgeDays: maxAgeDays, maxPerFile: maxPerFile),
  );

  Future<void> _setEnabled(BuildContext context, WidgetRef ref, VersionRetention retention, bool enabled) async {
    if (!enabled) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.localized.versionsTurnOffTitle,
        message: context.localized.versionsTurnOffMessage,
        confirmLabel: context.localized.versionsTurnOff,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    await _save(
      context,
      ref,
      enabled: enabled,
      maxAgeDays: retention.userMaxAgeDays,
      maxPerFile: retention.userMaxPerFile,
    );
  }

  Future<void> _choosePerFile(BuildContext context, WidgetRef ref, VersionRetention retention) async {
    final limit = retention.serverMaxPerFile;
    final count = await showCountInputDialog(
      context,
      title: context.localized.versionsMaxPerFile,
      label: limit == 0
          ? context.localized.versionsMaxPerFile
          : context.localized.versionsMaxPerFileHint(context.localized.versionsPerFile(limit)),
      initialValue: retention.maxPerFile,
      maximum: limit == 0 ? null : limit,
    );
    if (count == null || !context.mounted) return;
    await _save(context, ref, enabled: retention.userEnabled, maxAgeDays: retention.userMaxAgeDays, maxPerFile: count);
  }

  Future<void> _chooseAge(BuildContext context, WidgetRef ref, VersionRetention retention) async {
    final choice = await showRetentionPicker(
      context,
      title: context.localized.versionsMaxAge,
      selected: retention.userMaxAgeDays,
      followDefaultLabel:
          "${context.localized.versionsFollowServer} (${context.retentionDuration(retention.serverMaxAgeDays)})",
    );
    if (choice == null || !context.mounted) return;
    await _save(
      context,
      ref,
      enabled: retention.userEnabled,
      maxAgeDays: choice.days,
      maxPerFile: retention.userMaxPerFile,
    );
  }
}
