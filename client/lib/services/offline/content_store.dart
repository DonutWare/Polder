import "dart:typed_data";

import "package:crypto/crypto.dart";

abstract interface class OfflineContentStore {
  Future<String> write(Uint8List bytes);

  Future<String> writeStream(Stream<List<int>> bytes);

  Future<Uint8List?> read(String hash);

  Stream<List<int>> openRead(String hash);

  Future<int?> length(String hash);

  Future<void> retainOnly(Set<String> hashes);
}

String contentHash(List<int> bytes) => sha256.convert(bytes).toString();

class DeviceStorageFullException implements Exception {
  const DeviceStorageFullException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MissingContentException implements Exception {
  const MissingContentException(this.hash);

  final String hash;

  @override
  String toString() => "MissingContentException($hash)";
}
