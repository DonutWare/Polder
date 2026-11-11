import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";

import "package:polder/services/offline/file_content_store.dart";

void main() {
  late Directory directory;
  late FileContentStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp("content_store_test");
    store = FileContentStore(directory);
  });

  tearDown(() => directory.delete(recursive: true));

  Future<List<File>> files() async =>
      [await for (final entity in directory.list(recursive: true)) ?entity as File?]
        ..retainWhere((file) => file.existsSync());

  test("a write that fails halfway leaves nothing behind", () async {
    final failing = Stream<List<int>>.fromIterable([
      [1, 2, 3],
    ]).followedBy(Stream.error(const FileSystemException("connection lost")));

    await expectLater(store.writeStream(failing), throwsA(isA<FileSystemException>()));

    expect(await files(), isEmpty);
  });

  test("content written moments ago survives a cleanup before it is recorded", () async {
    final hash = await store.write(Uint8List.fromList([1, 2, 3]));

    await store.retainOnly(const {});

    expect(await store.length(hash), 3);
  });
}

extension<T> on Stream<T> {
  Stream<T> followedBy(Stream<T> next) async* {
    yield* this;
    yield* next;
  }
}
