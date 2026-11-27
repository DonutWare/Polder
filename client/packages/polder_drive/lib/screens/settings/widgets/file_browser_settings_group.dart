import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "package:polder_drive/providers/file_browser/file_browser_location_provider.dart";
import "package:polder_drive/providers/drive_service_providers.dart";
import "package:polder_drive/services/mount/file_browser_location.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";
import "package:polder_ui/widgets/shared/notice_tile.dart";

class FileBrowserSettingsGroup extends ConsumerWidget {
  const FileBrowserSettingsGroup({super.key});

  static final _fileProviderSettings = Uri.parse(
    "x-apple.systempreferences:com.apple.ExtensionsPreferences?extensionPointIdentifier=com.apple.fileprovider-nonui",
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(showInFileBrowserProvider).value;
    if (ref.watch(fileBrowserLocationProvider) == null || shown == null) return const SizedBox.shrink();
    final localized = context.localized;
    final turnedOffInSystem = shown && ref.watch(fileBrowserLocationEnabledProvider).value == false;
    return NavGroup(
      title: fileBrowserName,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(usesFilesApp ? localized.showInFilesApp : localized.showInFinder),
          subtitle: Text(usesFilesApp ? localized.showInFilesAppHint : localized.showInFinderHint),
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
        title: usesFilesApp ? context.localized.filesAppRemoveTitle : context.localized.finderRemoveTitle,
        message: usesFilesApp ? context.localized.filesAppRemoveMessage : context.localized.finderRemoveMessage,
        confirmLabel: context.localized.remove,
        destructive: true,
      );
      if (!confirmed) return;
    }
    await ref.read(showInFileBrowserProvider.notifier).setShown(shown);
  }
}
