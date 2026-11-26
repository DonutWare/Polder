import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_calendar_app/calendar_app.dart";
import "package:polder_calendar_app/calendar_app_overrides.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_core/util/device_name.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/services/notifications/plugin_notification_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SingleSignOn.config = const SingleSignOnConfig(
    appName: "Polder Calendar",
    callbackScheme: isDevFlavor ? "polder-calendar-dev" : "polder-calendar",
  );
  final deviceName = await DeviceName.resolve();
  final notifications = await PluginNotificationService.initialize();
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        deviceNameProvider.overrideWithValue(deviceName),
        notificationServiceProvider.overrideWithValue(notifications),
        ...calendarAppOverrides,
      ],
      child: const CalendarApp(),
    ),
  );
}
