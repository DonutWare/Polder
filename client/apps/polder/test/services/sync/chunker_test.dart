import "dart:io";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/services/sync/chunker.dart";

Uint8List xorshiftTestData(int size) {
  final bytes = ByteData(size);
  var x = 1;
  for (var i = 0; i < size; i += 8) {
    x ^= x >>> 12;
    x ^= x << 25;
    x ^= x >>> 27;
    bytes.setInt64(i, x * 0x2545F4914F6CDD1D, Endian.little);
  }
  return bytes.buffer.asUint8List();
}

void main() {
  const expectedOffsets = [0, 1253242, 2964301, 4034138, 5319580, 6665121];
  const fileHash = "759d208d2614cac1f212124b443399413c6334224d3ae2dbf6b4f660787f4546";
  final data = xorshiftTestData(8388608);

  test("gear table matches the protocol test vectors", () {
    expect(FastCdc.gear[0], 0x508530c361960c3c);
    expect(FastCdc.gear[1], 0x452929d50b3206af);
    expect(FastCdc.gear[255], 0xe15c986498e07891);
  });

  test("test data has the protocol whole-file hash", () {
    expect(sha256.convert(data).toString(), fileHash);
  });

  test("in-memory chunking matches the protocol offsets and hashes", () {
    final manifest = FastCdc.manifestOfBytes(data);

    expect(manifest.chunks.map((chunk) => chunk.offset), expectedOffsets);
    expect(manifest.chunks.last.end, 8388608);
    expect(manifest.chunks.first.hash, startsWith("af0abd0190233db4"));
    expect(manifest.hash, fileHash);
  });

  test("file chunking is identical to in-memory chunking", () async {
    final directory = await Directory.systemTemp.createTemp("polder_chunker");
    addTearDown(() => directory.delete(recursive: true));
    final file = File("${directory.path}/vector.bin");
    await file.writeAsBytes(data);

    final manifest = await FastCdc.manifestOfFile(file);

    expect(manifest, FastCdc.manifestOfBytes(data));
  });

  test("files smaller than minSize are a single chunk", () {
    final small = Uint8List.fromList(List.filled(1000, 7));

    final manifest = FastCdc.manifestOfBytes(small);

    expect(manifest.chunks, hasLength(1));
    expect(manifest.chunks.single.size, 1000);
  });

  test("an empty file has no chunks", () {
    expect(FastCdc.manifestOfBytes(Uint8List(0)).chunks, isEmpty);
  });
}
