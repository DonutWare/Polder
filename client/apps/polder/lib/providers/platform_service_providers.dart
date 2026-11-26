import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/services/desktop/launch_at_login.dart";
import "package:polder/services/mount/file_browser_location.dart";
import "package:polder/services/transfer/document_scanner_service.dart";
import "package:polder_core/util/flavor.dart";

final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) => const NativeDocumentScannerService());

final fileBrowserLocationProvider = Provider<FileBrowserLocation?>(
  (ref) => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || _finderEnabled)
      ? const ChannelFileBrowserLocation()
      : null,
);

bool get _finderEnabled => desktopIntegrationsEnabled && defaultTargetPlatform == TargetPlatform.macOS;

final launchAtLoginProvider = Provider<LaunchAtLogin?>(
  (ref) => desktopIntegrationsEnabled && !kIsWeb ? createLaunchAtLogin() : null,
);
