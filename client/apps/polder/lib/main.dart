import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:media_kit/media_kit.dart";
import "package:polder/polder_app.dart";
import "package:polder_calendar/providers/calendar/calendar_providers.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_drive/services/background/notification_action_handler.dart";
import "package:polder_ui/services/notifications/plugin_notification_service.dart";
import "package:polder_drive/services/sync/sync_platform_factory.dart";
import "package:polder_core/util/device_name.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:polder_ui/widgets/shared/polder_logo.dart";
import "package:polder/app_overrides.dart";
import "package:polder/services/background/background_dispatcher.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_core/providers/calendar/calendar_source_providers.dart";

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  usePathUrlStrategy();
  SingleSignOn.config = const SingleSignOnConfig(
    appName: "Polder",
    callbackScheme: isDevFlavor ? "polder-dev" : "polder",
    onBrowserReturn: showDesktopWindow,
  );
  if (kIsWeb) await BrowserContextMenu.disableContextMenu();
  await initializeBackgroundSync(backgroundCallbackDispatcher);
  await initializeDesktopWindow(arguments);
  unawaited(precachePolderIcon());
  final deviceName = await DeviceName.resolve();
  final featureModes = await FeatureModes.read(SharedPreferencesStore());
  final installedCompanions = featureModes.needsDetection ? await FeatureModes.detectInstalled() : <PolderFeature>{};
  final notifications = await PluginNotificationService.initialize(onBackgroundResponse: notificationActionDispatcher);
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        ...polderPackageOverrides,
        deviceNameProvider.overrideWithValue(deviceName),
        featureModesSeedProvider.overrideWithValue(featureModes),
        installedCompanionsSeedProvider.overrideWithValue(installedCompanions),
        notificationServiceProvider.overrideWithValue(notifications),
        polderCalendarSourcesOverride,
        calendarReminderNoticeOverride,
      ],
      child: const PolderApp(),
    ),
  );
}
