import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_core/util/device_name.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder_drive/desktop/sync_tray.dart";
import "package:polder_drive/services/background/notification_action_handler.dart";
import "package:polder_drive/services/sync/sync_platform_factory.dart";
import "package:polder_drive_app/drive_app.dart";
import "package:polder_drive_app/drive_app_overrides.dart";
import "package:polder_drive_app/services/drive_background_dispatcher.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/services/notifications/plugin_notification_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SingleSignOn.config = const SingleSignOnConfig(
    appName: "Polder Drive",
    callbackScheme: isDevFlavor ? "polder-drive-dev" : "polder-drive",
    onBrowserReturn: showDesktopWindow,
  );
  await initializeBackgroundSync(driveBackgroundDispatcher);
  await initializeDesktopWindow();
  final deviceName = await DeviceName.resolve();
  final notifications = await PluginNotificationService.initialize(
    onBackgroundResponse: notificationActionDispatcher,
    windows: WindowsNotificationIdentity.drive,
  );
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        deviceNameProvider.overrideWithValue(deviceName),
        notificationServiceProvider.overrideWithValue(notifications),
        ...driveAppOverrides,
      ],
      child: const DriveApp(),
    ),
  );
}
