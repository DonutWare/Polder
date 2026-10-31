import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:media_kit/media_kit.dart";
import "package:polder/polder_app.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/sync/unsupported_sync_platform.dart";
import "package:polder/util/device_name.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:polder/widgets/shared/polder_logo.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  usePathUrlStrategy();
  if (kIsWeb) await BrowserContextMenu.disableContextMenu();
  await initializeBackgroundSync();
  await initializeDesktopWindow();
  unawaited(precachePolderIcon());
  final deviceName = await DeviceName.resolve();
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [deviceNameProvider.overrideWithValue(deviceName)],
      child: const PolderApp(),
    ),
  );
}
