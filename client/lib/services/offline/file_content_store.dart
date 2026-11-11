import "dart:io";
import "dart:isolate";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:path/path.dart" as p;

import "package:polder/services/offline/content_store.dart";

class FileContentStore implements OfflineContentStore {
  FileContentStore(this._directory);

  final Directory _directory;
  var _tempCounter = 0;

  static const recentAge = Duration(minutes: 10);

  @override
  Future<String> write(Uint8List bytes) => writeStream(Stream.value(bytes));

  @override
  Future<String> writeStream(Stream<List<int>> bytes) {
    final temp = _tempFile();
    return _cleaningUp(temp, () async {
      await temp.parent.create(recursive: true);
      final sink = temp.openWrite();
      final hashSink = _DigestSink();
      final hasher = sha256.startChunkedConversion(hashSink);
      try {
        await for (final chunk in bytes) {
          hasher.add(chunk);
          sink.add(chunk);
        }
        hasher.close();
        await sink.flush();
      } finally {
        await sink.close();
      }
      return _place(temp, hashSink.value.toString());
    });
  }

  Future<String> adopt(String filePath) {
    final source = File(filePath);
    return _cleaningUp(source, () async => _place(source, await Isolate.run(() => _hashFile(filePath))));
  }

  Future<String> _cleaningUp(File temp, Future<String> Function() work) async {
    try {
      return await work();
    } on Object catch (error) {
      if (await temp.exists()) await temp.delete();
      if (error is FileSystemException && _outOfSpace(error)) throw DeviceStorageFullException(error.message);
      rethrow;
    }
  }

  static bool _outOfSpace(FileSystemException error) => const {28, 39, 112}.contains(error.osError?.errorCode);

  Future<String> _place(File source, String hash) async {
    final target = _fileFor(hash);
    if (await target.exists()) {
      await source.delete();
      await target.setLastModified(DateTime.now());
      return hash;
    }
    await target.parent.create(recursive: true);
    try {
      await source.rename(target.path);
    } on FileSystemException {
      await source.copy(target.path);
      await source.delete();
    }
    return hash;
  }

  static Future<String> _hashFile(String filePath) async {
    final sink = _DigestSink();
    final hasher = sha256.startChunkedConversion(sink);
    await File(filePath).openRead().forEach(hasher.add);
    hasher.close();
    return sink.value.toString();
  }

  @override
  Future<Uint8List?> read(String hash) async {
    final file = _fileFor(hash);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Stream<List<int>> openRead(String hash) async* {
    final file = _fileFor(hash);
    if (!await file.exists()) throw MissingContentException(hash);
    yield* file.openRead();
  }

  @override
  Future<int?> length(String hash) async {
    final file = _fileFor(hash);
    return await file.exists() ? file.length() : null;
  }

  @override
  Future<void> retainOnly(Set<String> hashes) async {
    if (!await _directory.exists()) return;
    await for (final entity in _directory.list(recursive: true)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      final temporary = name.startsWith(".tmp-");
      final unused = temporary || !hashes.contains(name);
      if (unused && await _olderThan(entity, temporary ? abandonedTempAge : recentAge)) await entity.delete();
    }
  }

  static const abandonedTempAge = Duration(days: 1);

  static Future<bool> _olderThan(File file, Duration age) async =>
      DateTime.now().difference(await file.lastModified()) > age;

  File _fileFor(String hash) => File(p.join(_directory.path, hash.substring(0, 2), hash));

  File _tempFile() => File(p.join(_directory.path, ".tmp-${DateTime.now().microsecondsSinceEpoch}-${_tempCounter++}"));
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
