import "package:polder/services/transfer/document_scanner_service.dart";

class FakeDocumentScannerService implements DocumentScannerService {
  List<String>? result;

  @override
  bool get isSupported => true;

  @override
  Future<List<String>?> scan({required ScannerAccent accent}) async => result;
}
