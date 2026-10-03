import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_web_plugins/url_strategy.dart";

import "package:nomad/bootstrap/nomad_app.dart";
import "package:nomad/services/sync/sync_platform_factory.dart";

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Real paths (/files, /admin) instead of #/files; the server falls back to index.html for them.
  usePathUrlStrategy();
  await initializeBackgroundSync();
  runApp(ProviderScope(retry: (_, _) => null, child: const NomadApp()));
}
