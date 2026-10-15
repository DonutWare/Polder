import "dart:io";

import "package:crypto/crypto.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/local_file_state.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/batch_uploader.dart";
import "package:polder/services/sync/sync_activity.dart";

import "../../support/fake_server.dart";
import "../../support/random_bytes.dart";

void main() {
  late Directory folder;
  late FakePolderServer server;
  late BatchUploader uploader;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp("polder_batch");
    server = FakePolderServer();
    uploader = BatchUploader(PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)));
  });

  tearDown(() => folder.delete(recursive: true));

  Future<UploadItem> item(String name, List<int> bytes, {int baseRev = 0}) async {
    final file = File("${folder.path}/$name");
    await file.writeAsBytes(bytes);
    final stat = await file.stat();
    return UploadItem(
      source: file,
      remotePath: "/$name",
      local: LocalFileState(
        relativePath: name,
        size: stat.size,
        mtime: stat.modified,
        hash: sha256.convert(bytes).toString(),
      ),
      baseRev: baseRev,
    );
  }

  int requestsTo(String route) => server.requests.where((request) => request == route).length;

  test("many files go up in one batch and one stream, and identical content is sent once", () async {
    final items = [
      for (var i = 0; i < 30; i++) await item("small-$i.txt", "content ${i % 10}".codeUnits),
      await item("large.bin", randomBytes(3 * 1024 * 1024)),
    ];

    final outcomes = await uploader.upload(items, group: "root");

    expect(outcomes.map((outcome) => outcome.error), everyElement(isNull));
    expect(requestsTo("POST /sync/batches"), 1);
    expect(server.requests.where((request) => request.endsWith("/stream")), hasLength(1));
    final distinctSmallBytes = [for (var i = 0; i < 10; i++) "content $i".length].reduce((a, b) => a + b);
    expect(server.chunkBytesReceived, distinctSmallBytes + 3 * 1024 * 1024);
    expect(String.fromCharCodes(server.contentOf("/small-17.txt")!), "content 7");
    expect(server.contentOf("/large.bin"), randomBytes(3 * 1024 * 1024));
  });

  test("a conflicting file fails on its own and the others are stored", () async {
    server.putFile("/taken.txt", "theirs".codeUnits);
    final items = [await item("taken.txt", "mine".codeUnits), await item("free.txt", "free".codeUnits)];

    final [taken, free] = await uploader.upload(items, group: "root");

    expect(taken.error, isA<ConflictException>().having((error) => error.current?.path, "current", "/taken.txt"));
    expect(free.result?.entry.path, "/free.txt");
    expect(String.fromCharCodes(server.contentOf("/taken.txt")!), "theirs");
  });

  test("a file that changes before its bytes are sent is reported as changed and the rest is stored", () async {
    final items = [await item("steady.txt", "steady".codeUnits), await item("moving.txt", "before".codeUnits)];
    final moving = items.last.source;
    await moving.writeAsString("after!");
    await moving.setLastModified(DateTime(2020));

    final [steady, changed] = await uploader.upload(items, group: "root");

    expect(steady.result, isNotNull);
    expect(
      changed.error,
      isA<SyncCancelledException>().having((error) => error.reason, "reason", CancelReason.changed),
    );
    expect(server.contentOf("/moving.txt"), isNull);
    expect(server.batches, isEmpty);
  });
}
