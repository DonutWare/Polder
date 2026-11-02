import "dart:typed_data";

import "package:polder/services/transfer/file_picker_service.dart";

class FakeFilePickerService implements FilePickerService {
  String? directory;
  final Map<String, Uri> browserSaves = {};

  @override
  bool savesInBrowser = false;

  @override
  Future<List<PickedFile>> pickFiles() async => [];

  @override
  Future<String?> pickDirectory() async => directory;

  @override
  Future<void> saveFile({required String name, required Uint8List bytes, required String mime}) async {}

  @override
  void saveFromUrl(Uri url, {required String name}) => browserSaves[name] = url;
}
