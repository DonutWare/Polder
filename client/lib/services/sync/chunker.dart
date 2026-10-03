import "dart:io";
import "dart:isolate";
import "dart:typed_data";

import "package:crypto/crypto.dart";

import "package:nomad/models/manifest.dart";

abstract final class FastCdc {
  static const int minSize = 256 * 1024;
  static const int avgSize = 1024 * 1024;
  static const int maxSize = 4 * 1024 * 1024;

  static const int _gearSeed = 0x4D65436C6F756421;
  static const int _splitmixGamma = 0x9E3779B97F4A7C15;
  static const int _splitmixFactor1 = 0xBF58476D1CE4E5B9;
  static const int _splitmixFactor2 = 0x94D049BB133111EB;
  static const int _strictMask = ((1 << 22) - 1) << 42;
  static const int _relaxedMask = ((1 << 18) - 1) << 46;

  static final List<int> gear = _buildGearTable();

  static List<int> _buildGearTable() {
    var state = _gearSeed;
    return List<int>.generate(256, (_) {
      state += _splitmixGamma;
      var z = state;
      z = (z ^ (z >>> 30)) * _splitmixFactor1;
      z = (z ^ (z >>> 27)) * _splitmixFactor2;
      return z ^ (z >>> 31);
    }, growable: false);
  }

  static int cutPoint(Uint8List data, int length) {
    if (length <= minSize) return length;
    final limit = length > maxSize ? maxSize : length;
    final normal = limit < avgSize ? limit : avgSize;
    var fingerprint = 0;
    var i = minSize;
    for (; i < normal; i++) {
      fingerprint = (fingerprint << 1) + gear[data[i]];
      if (fingerprint & _strictMask == 0) return i + 1;
    }
    for (; i < limit; i++) {
      fingerprint = (fingerprint << 1) + gear[data[i]];
      if (fingerprint & _relaxedMask == 0) return i + 1;
    }
    return limit;
  }

  static Manifest manifestOfBytes(Uint8List data) {
    final chunks = <ChunkRef>[];
    var offset = 0;
    while (offset < data.length) {
      final remaining = Uint8List.sublistView(data, offset);
      final cut = cutPoint(remaining, remaining.length);
      chunks.add(_chunkRef(Uint8List.sublistView(remaining, 0, cut), offset));
      offset += cut;
    }
    return Manifest(size: data.length, hash: sha256.convert(data).toString(), chunks: chunks);
  }

  /// Chunks and hashes [file] on a background isolate; it is CPU-bound and would otherwise stall the UI.
  static Future<Manifest> manifestOfFile(File file) {
    final path = file.path;
    return Isolate.run(() => _manifestOfFileSync(File(path)), debugName: "chunk ${file.uri.pathSegments.last}");
  }

  static Manifest _manifestOfFileSync(File file) {
    final chunks = <ChunkRef>[];
    final fileDigest = _DigestCollector();
    final fileHasher = sha256.startChunkedConversion(fileDigest);
    final reader = file.openSync();
    try {
      final buffer = Uint8List(maxSize);
      var filled = 0;
      var offset = 0;
      while ((filled = _fill(reader, buffer, filled)) > 0) {
        final cut = cutPoint(buffer, filled);
        final chunk = Uint8List.sublistView(buffer, 0, cut);
        fileHasher.add(chunk);
        chunks.add(_chunkRef(chunk, offset));
        offset += cut;
        buffer.setRange(0, filled - cut, buffer, cut);
        filled -= cut;
      }
    } finally {
      reader.closeSync();
    }
    fileHasher.close();
    return Manifest(size: chunks.fold(0, (sum, chunk) => sum + chunk.size), hash: fileDigest.hex, chunks: chunks);
  }

  static int _fill(RandomAccessFile reader, Uint8List buffer, int filled) {
    var total = filled;
    while (total < buffer.length) {
      final read = reader.readIntoSync(buffer, total);
      if (read == 0) break;
      total += read;
    }
    return total;
  }

  static ChunkRef _chunkRef(Uint8List chunk, int offset) =>
      ChunkRef(hash: sha256.convert(chunk).toString(), offset: offset, size: chunk.length);
}

class _DigestCollector implements Sink<Digest> {
  Digest? _digest;

  String get hex => _digest.toString();

  @override
  void add(Digest data) => _digest = data;

  @override
  void close() {}
}
