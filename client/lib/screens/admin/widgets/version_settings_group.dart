import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/count_input_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/retention_picker_dialog.dart";

class ServerVersionSettingsGroup extends ConsumerWidget {
  const ServerVersionSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(serverSettingsProvider).value;
    final notifier = ref.read(serverSettingsProvider.notifier);
    final localized = context.localized;
    if (settings == null) return const SizedBox.shrink();
    return NavGroup(
      title: localized.versionHistory,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.serverVersionsEnabled),
          subtitle: Text(localized.serverVersionsEnabledHint),
          value: settings.versionsEnabled,
          onChanged: (enabled) => _setEnabled(context, notifier, enabled),
        ),
        if (settings.versionsEnabled) ...[
          NavEntry(
            icon: IconsaxPlusLinear.timer_1,
            title: localized.versionsKeepAll,
            subtitle:
                "${localized.versionsHours(settings.versionsKeepAllHours)} · ${localized.serverVersionsLimitHint}. ${localized.serverVersionsKeepAllHint}",
            onTap: () => _chooseKeepAll(context, notifier, settings),
          ),
          NavEntry(
            icon: IconsaxPlusLinear.layer,
            title: localized.serverVersionsMaxPerFile,
            subtitle:
                "${localized.versionsPerFile(settings.versionsMaxPerFile)} · ${localized.serverVersionsLimitHint}",
            onTap: () => _choosePerFile(context, notifier, settings),
          ),
          NavEntry(
            icon: IconsaxPlusLinear.clock,
            title: localized.serverVersionsMaxAge,
            subtitle:
                "${context.retentionDuration(settings.versionsMaxAgeDays)} · ${localized.serverVersionsLimitHint}",
            onTap: () => _chooseAge(context, notifier, settings),
          ),
        ],
      ],
    );
  }

  Future<void> _setEnabled(BuildContext context, ServerSettingsNotifier notifier, bool enabled) async {
    if (!enabled) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.localized.versionsTurnOffTitle,
        message: context.localized.serverVersionsTurnOffMessage,
        confirmLabel: context.localized.turnOff,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    await context.runWithFeedback(notifier.setVersionsEnabled(enabled));
  }

  Future<void> _chooseKeepAll(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final hours = await showCountInputDialog(
      context,
      title: context.localized.versionsKeepAll,
      label: context.localized.versionsHoursLabel,
      initialValue: settings.versionsKeepAllHours,
    );
    if (hours != null && context.mounted) await context.runWithFeedback(notifier.setVersionsKeepAllHours(hours));
  }

  Future<void> _choosePerFile(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final count = await showCountInputDialog(
      context,
      title: context.localized.serverVersionsMaxPerFile,
      label: context.localized.quotaUnlimitedHint,
      initialValue: settings.versionsMaxPerFile,
    );
    if (count != null && context.mounted) await context.runWithFeedback(notifier.setVersionsMaxPerFile(count));
  }

  Future<void> _chooseAge(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final choice = await showRetentionPicker(
      context,
      title: context.localized.serverVersionsMaxAge,
      selected: settings.versionsMaxAgeDays,
    );
    final days = choice?.days;
    if (days != null && context.mounted) await context.runWithFeedback(notifier.setVersionsMaxAgeDays(days));
  }
}
