import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";

import "package:polder_drive/providers/sync/sync_platform_provider.dart";

class DriveNotificationSettingsGroup extends ConsumerWidget {
  const DriveNotificationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final preferences = ref.watch(notificationPreferencesProvider).value;
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final autoUpload = ref.watch(syncPlatformProvider).supportsAutoUpload;
    Widget toggle(IconData icon, String title, String hint, bool value, Future<void> Function(bool) change) =>
        SwitchListTile(
          secondary: Icon(icon),
          title: Text(title),
          subtitle: Text(hint),
          value: preferences != null && preferences.enabled && value,
          onChanged: preferences == null
              ? null
              : (enabled) async {
                  if (enabled && !await notifier.setEnabled(true)) return;
                  await change(enabled);
                },
        );
    return NavGroup(
      title: localized.notifications,
      children: [
        toggle(
          IconsaxPlusLinear.share,
          localized.notificationsShares,
          localized.notificationsSharesHint,
          preferences?.shares ?? false,
          notifier.setShares,
        ),
        if (autoUpload) ...[
          toggle(
            IconsaxPlusLinear.gallery_import,
            localized.notificationsUploadProgress,
            localized.notificationsUploadProgressHint,
            preferences?.autoUploadProgress ?? false,
            notifier.setUploadProgress,
          ),
          toggle(
            IconsaxPlusLinear.tick_circle,
            localized.notificationsUploadSummary,
            localized.notificationsUploadSummaryHint,
            preferences?.autoUploadSummary ?? false,
            notifier.setUploadSummary,
          ),
        ],
      ],
    );
  }
}
