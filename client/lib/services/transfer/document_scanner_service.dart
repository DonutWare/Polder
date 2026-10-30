import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:cunning_document_scanner/cunning_document_scanner.dart";

enum DocumentScanFailure { cameraDenied, other }

class DocumentScanException implements Exception {
  const DocumentScanException(this.failure, {this.reason = ""});

  final DocumentScanFailure failure;
  final String reason;
}

typedef ScannerAccent = ({Color light, Color dark});

abstract interface class DocumentScannerService {
  bool get isSupported;

  Future<List<String>?> scan({required ScannerAccent accent});
}

class NativeDocumentScannerService implements DocumentScannerService {
  const NativeDocumentScannerService();

  static const _channel = MethodChannel("polder/document_scanner");

  @override
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<List<String>?> scan({required ScannerAccent accent}) async {
    if (Platform.isIOS) await _setAccent(accent);
    try {
      return await CunningDocumentScanner.getPictures(
        scannerSource: ScannerSource.cameraAndGallery,
        iosScannerOptions: IosScannerOptions(imageFormat: IosImageFormat.jpg, jpgCompressionQuality: 0.85),
      );
    } on CunningDocumentScannerException catch (error) {
      throw DocumentScanException(
        error.code == "permission_denied" ? DocumentScanFailure.cameraDenied : DocumentScanFailure.other,
        reason: error.message,
      );
    }
  }

  Future<void> _setAccent(ScannerAccent accent) async {
    try {
      await _channel.invokeMethod<void>("setAccent", {
        "light": accent.light.toARGB32(),
        "dark": accent.dark.toARGB32(),
      });
    } on PlatformException {
      // The scanner still works in the system colors.
    }
  }
}
