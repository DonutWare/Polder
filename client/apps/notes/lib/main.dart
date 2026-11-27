import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_core/util/device_name.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder_notes_app/notes_app.dart";
import "package:polder_notes_app/notes_app_overrides.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SingleSignOn.config = const SingleSignOnConfig(
    appName: "Polder Notes",
    callbackScheme: isDevFlavor ? "polder-notes-dev" : "polder-notes",
  );
  final deviceName = await DeviceName.resolve();
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [deviceNameProvider.overrideWithValue(deviceName), ...notesAppOverrides],
      child: const NotesApp(),
    ),
  );
}
