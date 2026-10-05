import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:polder/polder_app.dart";
import "package:polder/services/sync/unsupported_sync_platform.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:polder/widgets/shared/polder_logo.dart";

Future<void> main() async => () async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeBackgroundSync();
  await initializeDesktopWindow();
  unawaited(precachePolderIcon());
  runApp(ProviderScope(retry: (_, _) => null, child: const PolderApp()));
}();
