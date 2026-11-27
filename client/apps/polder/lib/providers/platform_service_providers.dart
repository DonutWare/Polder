import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/services/desktop/launch_at_login.dart";
import "package:polder_core/util/flavor.dart";

export "package:polder_drive/providers/drive_service_providers.dart";

final launchAtLoginProvider = Provider<LaunchAtLogin?>(
  (ref) => desktopIntegrationsEnabled && !kIsWeb ? createLaunchAtLogin() : null,
);
