import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_drive/services/mount/file_browser_location.dart";
import "package:polder_drive/services/transfer/document_scanner_service.dart";
import "package:polder_core/util/flavor.dart";

final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) => const NativeDocumentScannerService());

final fileBrowserLocationProvider = Provider<FileBrowserLocation?>(
  (ref) => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || _finderEnabled)
      ? const ChannelFileBrowserLocation()
      : null,
);

bool get _finderEnabled => desktopIntegrationsEnabled && defaultTargetPlatform == TargetPlatform.macOS;
