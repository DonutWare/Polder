import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/desktop/launch_at_login_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/nav_group.dart";

class StartupSettingsGroup extends ConsumerWidget {
  const StartupSettingsGroup({super.key});

  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(launchAtLoginSettingsProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final localized = context.localized;
    final notifier = ref.read(launchAtLoginSettingsProvider.notifier);
    return NavGroup(
      title: localized.startup,
      children: [
        SwitchListTile(
          contentPadding: _padding,
          title: Text(localized.launchAtLogin),
          subtitle: Text(localized.launchAtLoginHint),
          value: settings.enabled,
          onChanged: notifier.setEnabled,
        ),
        if (settings.enabled)
          SwitchListTile(
            contentPadding: _padding,
            title: Text(localized.launchMinimized),
            subtitle: Text(localized.launchMinimizedHint),
            value: settings.minimized,
            onChanged: notifier.setMinimized,
          ),
      ],
    );
  }
}
