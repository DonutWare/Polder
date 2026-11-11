import "dart:typed_data";

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/services/offline/content_store.dart";
import "package:polder/services/offline/db_content_store.dart";
import "package:polder/services/offline/offline_database.dart";

void main() {
  late OfflineDatabase db;
  late DbContentStore store;

  setUp(() {
    db = OfflineDatabase(NativeDatabase.memory());
    store = DbContentStore(db);
  });

  tearDown(() => db.close());

  Stream<List<int>> pieces(int count, int size) async* {
    for (var i = 0; i < count; i++) {
      yield Uint8List(size)..fillRange(0, size, i);
    }
  }

  test("a streamed file is written in chunks and read back as it was", () async {
    final expected = BytesBuilder();
    await pieces(10, 300 * 1024).forEach(expected.add);
    final bytes = expected.takeBytes();

    final hash = await store.writeStream(pieces(10, 300 * 1024));

    expect(hash, contentHash(bytes));
    expect(await store.length(hash), bytes.length);
    final chunks = await store.openRead(hash).toList();
    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => chunk.length <= DbContentStore.chunkSize + 300 * 1024), isTrue);
    expect(chunks.expand((chunk) => chunk).toList(), bytes);
  });

  test("writing the same content twice keeps one copy", () async {
    final first = await store.write(Uint8List.fromList([1, 2, 3]));
    final second = await store.writeStream(Stream.value([1, 2, 3]));

    expect(second, first);
    await store.retainOnly({first});
    expect(await store.read(first), [1, 2, 3]);
  });

  test("garbage collection drops content nothing refers to", () async {
    final kept = await store.write(Uint8List.fromList([1]));
    final dropped = await store.write(Uint8List.fromList([2]));

    await store.retainOnly({kept});

    expect(await store.contains(kept), isTrue);
    expect(await store.contains(dropped), isFalse);
  });
}
