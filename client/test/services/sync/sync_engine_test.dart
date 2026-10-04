import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";

import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/api/api_client_factory.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/in_memory_sync_state_store.dart";
import "package:nomad/services/sync/sync_engine.dart";

import "../../support/fake_server.dart";
import "../../support/random_bytes.dart";

void main() {
  late Directory localRoot;
  late FakeNomadServer server;
  late InMemorySyncStateStore store;
  late SyncEngine engine;
  late SyncRoot root;

  File local(String relativePath) => File("${localRoot.path}/$relativePath");

  setUp(() async {
    localRoot = await Directory.systemTemp.createTemp("nomad_sync");
    server = FakeNomadServer();
    store = InMemorySyncStateStore();
    final api = NomadApi(ApiClientFactory.create("https://cloud.test", httpClient: server));
    engine = SyncEngine(api: api, store: store, deviceName: "Laptop", clock: () => DateTime(2026, 9, 30, 14, 5));
    root = SyncRoot(id: "root", accountId: "a", localPath: localRoot.path, remotePath: "/Docs");
  });

  tearDown(() => localRoot.delete(recursive: true));

  test("first sync downloads the remote tree and records it", () async {
    final big = randomBytes(1500000);
    server
      ..putFile("/Docs/a.txt", "hello".codeUnits)
      ..putFile("/Docs/sub/big.bin", big)
      ..putFile("/Other/ignored.txt", "x".codeUnits);

    final report = await engine.run(root);

    expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
    expect(await local("a.txt").readAsString(), "hello");
    expect(await local("sub/big.bin").readAsBytes(), big);
    expect(await local("../Other").exists(), isFalse);
    final entries = await store.entries("root");
    expect(entries.keys, containsAll(["a.txt", "sub", "sub/big.bin"]));
    expect(entries["sub/big.bin"]!.state, EntryState.hydrated);
    expect(await store.cursor("root"), greaterThan(0));
  });

  test("new local files are uploaded and a second run is a no-op", () async {
    await local("notes.txt").writeAsString("local notes");
    await Directory("${localRoot.path}/photos").create();
    await local("photos/p.jpg").writeAsBytes(randomBytes(600000));

    final first = await engine.run(root);
    final second = await engine.run(root);

    expect(first.uploaded, 3);
    expect(String.fromCharCodes(server.contentOf("/Docs/notes.txt")!), "local notes");
    expect(server.contentOf("/Docs/photos/p.jpg"), await local("photos/p.jpg").readAsBytes());
    expect(second.uploaded + second.downloaded + second.deleted, 0);
  });

  test("a small local edit to a large file uploads only the changed chunks", () async {
    final original = randomBytes(6 * 1024 * 1024);
    server.putFile("/Docs/video.bin", original);
    await engine.run(root);
    final edited = Uint8List.fromList(original)..setRange(3000000, 3000010, List.filled(10, 7));
    await local("video.bin").writeAsBytes(edited);
    server.chunkBytesReceived = 0;

    final report = await engine.run(root);

    expect(report.uploaded, 1);
    expect(server.contentOf("/Docs/video.bin"), edited);
    expect(server.chunkBytesReceived, lessThan(original.length ~/ 2));
  });

  test("a small remote edit to a large file downloads only the changed ranges", () async {
    final original = randomBytes(6 * 1024 * 1024);
    server.putFile("/Docs/video.bin", original);
    await engine.run(root);
    final edited = Uint8List.fromList(original)..setRange(100, 110, List.filled(10, 9));
    server
      ..putFile("/Docs/video.bin", edited)
      ..rangeBytesServed = 0;

    final report = await engine.run(root);

    expect(report.downloaded, 1);
    expect(await local("video.bin").readAsBytes(), edited);
    expect(server.rangeBytesServed, lessThan(original.length ~/ 2));
  });

  test("deletes propagate in both directions", () async {
    server
      ..putFile("/Docs/remote-gone.txt", "a".codeUnits)
      ..putFile("/Docs/local-gone.txt", "b".codeUnits);
    await engine.run(root);
    server.deletePath("/Docs/remote-gone.txt");
    await local("local-gone.txt").delete();

    final report = await engine.run(root);

    expect(report.deleted, 2);
    expect(await local("remote-gone.txt").exists(), isFalse);
    expect(server.contentOf("/Docs/local-gone.txt"), isNull);
  });

  test("changes on both sides become a conflict that keep both resolves", () async {
    server.putFile("/Docs/report.txt", "v1".codeUnits);
    await engine.run(root);
    await local("report.txt").writeAsString("mine");
    server.putFile("/Docs/report.txt", "theirs".codeUnits);

    final report = await engine.run(root);
    final conflict = report.conflicts.single;
    await engine.resolve(root, conflict, ConflictResolution.keepBoth);

    expect(conflict.kind, ConflictKind.bothModified);
    const copyName = "report (conflict Laptop 2026-09-30 1405).txt";
    expect(await local("report.txt").readAsString(), "theirs");
    expect(await local(copyName).readAsString(), "mine");
    expect(String.fromCharCodes(server.contentOf("/Docs/$copyName")!), "mine");
    expect((await engine.run(root)).conflicts, isEmpty);
  });

  test("keep mine overwrites the server version against its current rev", () async {
    server.putFile("/Docs/report.txt", "v1".codeUnits);
    await engine.run(root);
    await local("report.txt").writeAsString("mine");
    server.putFile("/Docs/report.txt", "theirs".codeUnits);
    final conflict = (await engine.run(root)).conflicts.single;

    await engine.resolve(root, conflict, ConflictResolution.keepMine);

    expect(String.fromCharCodes(server.contentOf("/Docs/report.txt")!), "mine");
  });

  test("keep server's after a remote delete removes the local file", () async {
    server.putFile("/Docs/report.txt", "v1".codeUnits);
    await engine.run(root);
    await local("report.txt").writeAsString("mine");
    server.deletePath("/Docs/report.txt");
    final conflict = (await engine.run(root)).conflicts.single;

    await engine.resolve(root, conflict, ConflictResolution.keepServer);

    expect(conflict.kind, ConflictKind.localModifiedRemoteDeleted);
    expect(await local("report.txt").exists(), isFalse);
  });

  test("a missing local root fails instead of deleting everything remotely", () async {
    server.putFile("/Docs/a.txt", "a".codeUnits);
    await engine.run(root);
    await localRoot.delete(recursive: true);

    await expectLater(engine.run(root), throwsA(anything));

    expect(server.contentOf("/Docs/a.txt"), isNotNull);
    await localRoot.create();
  });

  test("auto-upload mode only uploads", () async {
    final uploadRoot = root.copyWith(mode: SyncMode.autoUpload);
    server.putFile("/Docs/remote.jpg", "r".codeUnits);
    await local("camera.jpg").writeAsBytes(randomBytes(1000));
    await Directory("${localRoot.path}/.thumbnails").create();
    await local(".thumbnails/.nomedia").writeAsString("");
    await local(".trashed-1760000000-deleted.jpg").writeAsBytes(randomBytes(100));

    final report = await engine.run(uploadRoot);
    await local("camera.jpg").delete();
    await engine.run(uploadRoot);

    expect(report.uploaded, 1);
    expect(await local("remote.jpg").exists(), isFalse);
    expect(server.contentOf("/Docs/camera.jpg"), isNotNull);
    expect(server.nodes.keys.where((path) => path.contains("/.")), isEmpty);
  });

  test("auto-upload skips existing files but uploads new and edited ones", () async {
    final uploadRoot = root.copyWith(mode: SyncMode.autoUpload);
    await Directory("${localRoot.path}/2025").create();
    await local("2025/old.jpg").writeAsBytes(randomBytes(1000));
    await local("edited.jpg").writeAsBytes(randomBytes(1000));

    await engine.skipExisting(uploadRoot);
    await local("new.jpg").writeAsBytes(randomBytes(1000));
    await local("edited.jpg").writeAsBytes(randomBytes(1200));
    final report = await engine.run(uploadRoot);

    expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
    expect(report.uploaded, 2);
    expect(server.contentOf("/Docs/new.jpg"), isNotNull);
    expect(server.contentOf("/Docs/edited.jpg"), isNotNull);
    expect(server.contentOf("/Docs/2025/old.jpg"), isNull);
    expect(server.nodes.containsKey("/Docs/2025"), isFalse);
  });

  group("remote moves", () {
    late Directory otherLocalRoot;
    late SyncRoot otherRoot;

    File otherLocal(String relativePath) => File("${otherLocalRoot.path}/$relativePath");

    int contentDownloads() => server.requests.where((request) => request == "GET /files/content").length;

    setUp(() async {
      otherLocalRoot = await Directory.systemTemp.createTemp("nomad_sync_other");
      otherRoot = SyncRoot(id: "other", accountId: "a", localPath: otherLocalRoot.path, remotePath: "/Photos");
      await store.saveRoot(root);
      await store.saveRoot(otherRoot);
    });

    tearDown(() => otherLocalRoot.delete(recursive: true));

    test("a remote rename renames the local file instead of downloading it", () async {
      server.putFile("/Docs/draft.txt", "text".codeUnits);
      await engine.run(root);
      server.movePath("/Docs/draft.txt", "/Docs/final.txt");
      final downloadsBefore = contentDownloads();

      final report = await engine.run(root);

      expect(report.moved, 1);
      expect(report.downloaded + report.deleted, 0);
      expect(contentDownloads(), downloadsBefore);
      expect(await local("draft.txt").exists(), isFalse);
      expect(await local("final.txt").readAsString(), "text");
      expect((await store.entries("root")).keys, isNot(contains("draft.txt")));
      final second = await engine.run(root);
      expect(second.uploaded + second.downloaded + second.deleted + second.moved, 0);
    });

    test("a remote directory move moves its files", () async {
      server
        ..putFile("/Docs/old/a.txt", "a".codeUnits)
        ..putFile("/Docs/old/sub/b.txt", "b".codeUnits);
      await engine.run(root);
      server.movePath("/Docs/old", "/Docs/new");

      final report = await engine.run(root);

      expect(report.moved, 2);
      expect(report.downloaded, 0);
      expect(await Directory("${localRoot.path}/old").exists(), isFalse);
      expect(await local("new/a.txt").readAsString(), "a");
      expect(await local("new/sub/b.txt").readAsString(), "b");
      expect((await store.entries("root")).keys, containsAll(["new", "new/sub", "new/a.txt", "new/sub/b.txt"]));
    });

    test("a moved and then edited file is moved and only the difference downloaded", () async {
      final original = randomBytes(6 * 1024 * 1024);
      server.putFile("/Docs/video.bin", original);
      await engine.run(root);
      server.movePath("/Docs/video.bin", "/Docs/clips/video.bin");
      final edited = Uint8List.fromList(original)..setRange(100, 110, List.filled(10, 9));
      server
        ..putFile("/Docs/clips/video.bin", edited)
        ..rangeBytesServed = 0;

      final report = await engine.run(root);

      expect(report.moved, 1);
      expect(report.downloaded, 1);
      expect(await local("video.bin").exists(), isFalse);
      expect(await local("clips/video.bin").readAsBytes(), edited);
      expect(server.rangeBytesServed, lessThan(original.length ~/ 2));
    });

    test("a locally edited file is not moved over", () async {
      server.putFile("/Docs/a.txt", "v1".codeUnits);
      await engine.run(root);
      await local("a.txt").writeAsString("mine");
      server.movePath("/Docs/a.txt", "/Docs/b.txt");

      final report = await engine.run(root);

      expect(report.moved, 0);
      expect(await local("b.txt").readAsString(), "v1");
      expect(await local("a.txt").readAsString(), "mine");
      expect(report.conflicts.single.kind, ConflictKind.localModifiedRemoteDeleted);
    });

    for (final sourceFirst in [true, false]) {
      test(
        "a move between sync roots moves the local file (${sourceFirst ? "source" : "target"} root first)",
        () async {
          server
            ..putFile("/Docs/a.txt", "a".codeUnits)
            ..putFile("/Photos/keep.jpg", "k".codeUnits);
          await engine.run(root);
          await engine.run(otherRoot);
          server.movePath("/Docs/a.txt", "/Photos/2026/a.txt");
          final downloadsBefore = contentDownloads();

          final first = await engine.run(sourceFirst ? root : otherRoot);
          final second = await engine.run(sourceFirst ? otherRoot : root);

          expect(first.moved, 1);
          expect(second.moved + second.downloaded + second.deleted + second.uploaded, 0);
          expect(contentDownloads(), downloadsBefore);
          expect(await local("a.txt").exists(), isFalse);
          expect(await otherLocal("2026/a.txt").readAsString(), "a");
          expect((await store.entries("root")).keys, isNot(contains("a.txt")));
          expect((await store.entries("other")).keys, contains("2026/a.txt"));
        },
      );
    }

    test("a move into a folder that is not synced deletes the local file", () async {
      server.putFile("/Docs/a.txt", "a".codeUnits);
      await engine.run(root);
      server.movePath("/Docs/a.txt", "/Elsewhere/a.txt");

      final report = await engine.run(root);

      expect(report.moved, 0);
      expect(report.deleted, 1);
      expect(await local("a.txt").exists(), isFalse);
    });
  });
}
