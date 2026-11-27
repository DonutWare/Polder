import "package:flutter_riverpod/misc.dart";
import "package:polder_core/providers/sync/sync_request_provider.dart";
import "package:polder_drive/providers/drive_service_providers.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/providers/sync/sync_scheduler_provider.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";

import "package:polder_drive_app/routes/drive_app_router.dart";
import "package:polder_drive_app/routes/drive_app_routes.dart";

final List<Override> driveAppOverrides = [
  polderUiConfigProvider.overrideWithValue(
    const PolderUiConfig(
      afterSignIn: _afterSignIn,
      accountSettings: DriveAppRoutes.settings,
      upFrom: DriveAppRoutes.upFrom,
      isTopLevel: DriveAppRoutes.isTopLevel,
      pageActions: [SettingsButton(onlyOnPhone: true)],
      menuButton: AccountMenuButton(),
    ),
  ),
  historyRouterProvider.overrideWith((ref) => ref.watch(driveRouterProvider)),
  syncRequestProvider.overrideWith(
    (ref) =>
        () => ref.read(syncSchedulerProvider)?.requestRun(),
  ),
  notificationChecksSchedulerProvider.overrideWith((ref) => ref.watch(syncPlatformProvider).scheduleNotificationChecks),
  fileBrowserLocationProvider.overrideWithValue(null),
];

String _afterSignIn(Uri loginLocation) => DriveAppRoutes.signIn.afterSignIn(loginLocation);
