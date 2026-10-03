import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/providers/sync/auto_upload_settings_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/async_value_view.dart";
import "package:nomad/widgets/shared/nav_group.dart";

class AutoUploadSettingsSection extends ConsumerWidget {
  const AutoUploadSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(autoUploadSettingsProvider.notifier);
    return AsyncValueView<AutoUploadSettings>(
      value: ref.watch(autoUploadSettingsProvider),
      data: (settings) => NavGroup(
        title: context.localized.autoUploadEnabled,
        children: [
          SwitchListTile(
            title: Text(context.localized.autoUploadEnabled),
            subtitle: Text(context.localized.autoUploadDescription),
            value: settings.enabled,
            onChanged: notifier.setEnabled,
          ),
          SwitchListTile(
            title: Text(context.localized.wifiOnly),
            value: settings.wifiOnly,
            onChanged: settings.enabled ? notifier.setWifiOnly : null,
          ),
          SwitchListTile(
            title: Text(context.localized.chargingOnly),
            value: settings.chargingOnly,
            onChanged: settings.enabled ? notifier.setChargingOnly : null,
          ),
        ],
      ),
    );
  }
}
