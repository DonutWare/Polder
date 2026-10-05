import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:nomad/nomad_app.dart";
import "package:nomad/services/sync/unsupported_sync_platform.dart";
import "package:nomad/widgets/desktop/desktop_tray.dart";
import "package:nomad/widgets/shared/polder_logo.dart";

Future<void> main() async => () async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeBackgroundSync();
  await initializeDesktopWindow();
  unawaited(precachePolderIcon());
  runApp(ProviderScope(retry: (_, _) => null, child: const NomadApp()));
}();
