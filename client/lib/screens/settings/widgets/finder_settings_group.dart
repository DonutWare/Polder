import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "package:polder/providers/desktop/finder_location_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/notice_tile.dart";

class FinderSettingsGroup extends ConsumerWidget {
  const FinderSettingsGroup({super.key});

  static final _fileProviderSettings = Uri.parse(
    "x-apple.systempreferences:com.apple.ExtensionsPreferences?extensionPointIdentifier=com.apple.fileprovider-nonui",
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(showInFinderProvider).value;
    if (ref.watch(finderLocationProvider) == null || shown == null) return const SizedBox.shrink();
    final localized = context.localized;
    final turnedOffInSystem = shown && ref.watch(finderLocationEnabledProvider).value == false;
    return NavGroup(
      title: "Finder",
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.showInFinder),
          subtitle: Text(localized.showInFinderHint),
          value: shown,
          onChanged: (value) => _setShown(context, ref, value),
        ),
        if (turnedOffInSystem)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NoticeTile(
              icon: IconsaxPlusLinear.folder_cloud,
              color: AppColors.of(context).warning,
              text: localized.finderLocationDisabled,
              action: FilledButton.tonal(
                onPressed: () => launchUrl(_fileProviderSettings),
                child: Text(localized.openSystemSettings),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _setShown(BuildContext context, WidgetRef ref, bool shown) async {
    if (!shown) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.localized.finderRemoveTitle,
        message: context.localized.finderRemoveMessage,
        confirmLabel: context.localized.remove,
        destructive: true,
      );
      if (!confirmed) return;
    }
    await ref.read(showInFinderProvider.notifier).setShown(shown);
  }
}
