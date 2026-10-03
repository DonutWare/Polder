import "dart:typed_data";

import "package:file_picker/file_picker.dart";

abstract interface class PickedFile {
  String get name;

  Future<int?> length();

  Stream<List<int>> openRead();
}

abstract interface class FilePickerService {
  Future<List<PickedFile>> pickFiles();

  Future<String?> pickDirectory();

  Future<void> saveFile({required String name, required Uint8List bytes, required String mime});
}

class PlatformFilePickerService implements FilePickerService {
  const PlatformFilePickerService();

  static final Future<void> _unsandboxedMacOsReady = FilePicker.skipEntitlementsChecks();

  @override
  Future<List<PickedFile>> pickFiles() async {
    await _unsandboxedMacOsReady;
    return (await FilePicker.pickFiles()).map(_PlatformPickedFile.new).toList();
  }

  @override
  Future<String?> pickDirectory() async {
    await _unsandboxedMacOsReady;
    return FilePicker.getDirectoryPath();
  }

  @override
  Future<void> saveFile({required String name, required Uint8List bytes, required String mime}) async {
    await _unsandboxedMacOsReady;
    await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: mime.isEmpty ? "application/octet-stream" : mime);
  }
}

class _PlatformPickedFile implements PickedFile {
  const _PlatformPickedFile(this._file);

  final PlatformFile _file;

  @override
  String get name => _file.name;

  @override
  Future<int?> length() => _file.length();

  @override
  Stream<List<int>> openRead() => _file.readAsByteStream();
}
