import "package:flutter/foundation.dart";

import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_core/util/flavor.dart";

import "package:polder/services/desktop/launch_at_login.dart";

/// Whether this launch came from login with "launch minimized" turned on.
Future<bool> launchedMinimized(List<String> arguments) async {
  final launchAtLogin = desktopIntegrationsEnabled && !kIsWeb ? createLaunchAtLogin() : null;
  if (launchAtLogin == null || !await launchAtLogin.launchedAtLogin(arguments)) return false;
  return LaunchMinimizedPreference(SharedPreferencesStore()).read();
}
