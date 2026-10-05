import "dart:io";
import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:path/path.dart" as p;

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

class LocalPickedFile implements PickedFile {
  LocalPickedFile(String path, {String? name}) : _file = File(path), name = name ?? p.basename(path);

  final File _file;

  @override
  final String name;

  @override
  Future<int?> length() => _file.length();

  @override
  Stream<List<int>> openRead() => _file.openRead();
}

class BytesPickedFile implements PickedFile {
  const BytesPickedFile(this.name, this._bytes);

  @override
  final String name;

  final Uint8List _bytes;

  @override
  Future<int?> length() async => _bytes.length;

  @override
  Stream<List<int>> openRead() => Stream.value(_bytes);
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
