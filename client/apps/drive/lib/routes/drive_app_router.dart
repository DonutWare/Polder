import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_drive/routes/drive_router_routes.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/screens/settings/widgets/drive_notification_settings_group.dart";
import "package:polder_drive/screens/settings/widgets/file_browser_settings_group.dart";
import "package:polder_drive/screens/settings/widgets/trash_settings_group.dart";
import "package:polder_drive/screens/browser/browser_stack.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/routes/standalone_router.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";

import "package:polder_drive_app/routes/drive_app_routes.dart";
import "package:polder_drive_app/widgets/drive_navigation.dart";

final driveRouterProvider = Provider<GoRouter>((ref) {
  final shellRoutes = driveShellRoutes(BrowsedPathMemory());
  return createStandaloneRouter(
    ref,
    signIn: DriveAppRoutes.signIn,
    settings: DriveAppRoutes.settings,
    title: (context) => AppLocalizations.of(context).navFiles,
    home: (location) => UpScope(
      child: BrowserStack(
        path: location.queryParameters[DriveRoutes.pathParameter] ?? RemotePath.root,
        select: location.queryParameters[DriveRoutes.selectParameter],
      ),
    ),
    sidebar: (location) => DriveSidebar(location: location),
    rail: (location) => DriveRail(location: location),
    railFooter: (location) => SettingsRailTile(location: location),
    settingsGroups: const [DriveNotificationSettingsGroup(), FileBrowserSettingsGroup(), TrashSettingsGroup()],
    routes: [for (final route in shellRoutes.skip(1)) route as GoRoute],
    fullScreenRoutes: driveFullScreenRoutes(),
  );
});
