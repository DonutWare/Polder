import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "../../support/fake_server.dart";

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/db_content_store.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/services/offline/offline_store.dart";

class _HoldingDownloader implements ContentDownloader {
  final enqueued = <String>[];
  Object? refuse;
  final finished = <String>{};
  final _events = StreamController<ContentDownloadEvent>.broadcast(sync: true);

  void finishQuietly(String path) => finished.add(path);

  void report(ContentDownloadEvent event) => _events.add(event);

  @override
  Stream<ContentDownloadEvent> get events => _events.stream;

  @override
  Future<Set<String>> queued() async => enqueued.toSet().difference(finished);

  @override
  Future<void> enqueue(OfflineFile file) async {
    if (refuse case final error?) throw error;
    enqueued.add(file.path);
  }

  @override
  Future<void> cancel(String path) async => enqueued.remove(path);

  @override
  Future<void> clearLeftovers() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakePolderServer server;
  late OfflineStore store;
  late OfflineFiles files;
  late DateTime now;

  Uint8List text(String value) => Uint8List.fromList(utf8.encode(value));

  String serverText(String path) => utf8.decode(server.contentOf(path)!);

  Future<String?> localText(String path) async {
    final bytes = await files.read(path);
    return bytes == null ? null : utf8.decode(bytes);
  }

  Future<List<OutboxEntry>> outbox() => store.outbox(OutboxDomain.files);

  Future<void> sync() async {
    await files.push();
    await files.pull();
    await files.mirror();
    await files.whenDownloadsSettle();
  }

  setUp(() {
    now = DateTime.utc(2026, 11, 10, 12);
    server = FakePolderServer();
    final db = OfflineDatabase(NativeDatabase.memory());
    store = OfflineStore(db);
    files = OfflineFiles(
      api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)),
      store: store,
      content: DbContentStore(db),
      clock: () => now,
    );
  });

  tearDown(() => store.close());

  group("pinned folders", () {
    test("a pinned folder is listed and downloaded, then follows the change feed", () async {
      server.putFile("/Notes/Plan.md", utf8.encode("# Plan"));
      server.putFile("/Notes/Trips/Rome.md", utf8.encode("# Rome"));
      server.putFile("/Elsewhere.md", utf8.encode("not pinned"));
      await files.pinNotes("/Notes");

      await sync();

      expect(await localText("/Notes/Plan.md"), "# Plan");
      expect(await localText("/Notes/Trips/Rome.md"), "# Rome");
      expect(await files.file("/Elsewhere.md"), isNull);
      expect((await files.children("/Notes")).map((file) => file.entry.name), unorderedEquals(["Plan.md", "Trips"]));

      server.putFile("/Notes/Plan.md", utf8.encode("# Plan v2"));
      server.movePath("/Notes/Trips/Rome.md", "/Notes/Rome.md");
      server.deletePath("/Notes/Trips");
      await sync();

      expect(await localText("/Notes/Plan.md"), "# Plan v2");
      expect(await localText("/Notes/Rome.md"), "# Rome");
      expect(await files.file("/Notes/Trips"), isNull);
    });

    test("choosing another notes folder forgets the old one", () async {
      server.putFile("/Notes/Plan.md", utf8.encode("# Plan"));
      await files.pinNotes("/Notes");
      await sync();

      await files.pinNotes(null);

      expect(await files.tree("/Notes"), isEmpty);
    });
  });

  group("available offline", () {
    setUp(() {
      server.putFile("/Photos/a.jpg", utf8.encode("a"));
      server.putFile("/Photos/Trip/b.jpg", utf8.encode("bb"));
    });

    test("a folder made available offline is downloaded and counted", () async {
      await files.makeAvailableOffline("/Photos");
      await sync();

      expect(await localText("/Photos/Trip/b.jpg"), "bb");
      expect(await files.counts("/Photos"), (files: 2, ready: 2, bytes: 3, readyBytes: 3));
    });

    test("removing a folder from the device keeps it on the server", () async {
      await files.makeAvailableOffline("/Photos");
      await sync();

      await files.removeFromDevice("/Photos");

      expect(await files.pins(), isEmpty);
      expect(await files.tree("/Photos"), isEmpty);
      expect(serverText("/Photos/a.jpg"), "a");
      expect(server.requests.where((request) => request.startsWith("DELETE")), isEmpty);
    });

    test("removing one file inside an offline folder excludes only that file", () async {
      await files.makeAvailableOffline("/Photos");
      await sync();

      await files.removeFromDevice("/Photos/Trip/b.jpg");
      await sync();

      expect(await files.read("/Photos/Trip/b.jpg"), isNull);
      expect(await files.file("/Photos/Trip/b.jpg"), isNotNull);
      expect(await localText("/Photos/a.jpg"), "a");
      expect(serverText("/Photos/Trip/b.jpg"), "bb");
      expect(await files.counts("/Photos", skip: ["/Photos/Trip/b.jpg"]), (
        files: 1,
        ready: 1,
        bytes: 1,
        readyBytes: 1,
      ));

      await files.makeAvailableOffline("/Photos/Trip/b.jpg");
      await sync();

      expect(await localText("/Photos/Trip/b.jpg"), "bb");
      expect((await files.pins()).map((pin) => pin.kind), [OfflinePinKind.user]);
    });

    test("unsynced changes stay on the device when it is removed from the device", () async {
      await files.makeAvailableOffline("/Photos");
      await sync();
      server.unreachable = true;
      await files.write("/Photos/a.jpg", text("edited"));

      await files.removeFromDevice("/Photos");

      expect(await localText("/Photos/a.jpg"), "edited");
      expect(await outbox(), hasLength(1));
    });

    test("the notes folder cannot be removed from the device", () async {
      await files.pinNotes("/Photos");
      await sync();

      await files.removeFromDevice("/Photos/a.jpg");
      await files.makeAvailableOffline("/Photos/a.jpg");

      expect((await files.pins()).single.kind, OfflinePinKind.notes);
      expect(await localText("/Photos/a.jpg"), "a");
    });

    test("no more files than the download window are queued at once", () async {
      for (var i = 0; i < OfflineFiles.downloadWindow * 2; i++) {
        server.putFile("/Photos/many/$i.jpg", utf8.encode("$i"));
      }
      final downloader = _HoldingDownloader();
      final held = OfflineFiles(
        api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)),
        store: store,
        content: DbContentStore(store.db),
        downloader: downloader,
      );
      await held.makeAvailableOffline("/Photos");

      await held.mirror();
      await held.mirror();

      expect(downloader.enqueued, hasLength(OfflineFiles.downloadWindow));
      await held.dispose();
    });

    test("a finished download that is still being stored is not downloaded again", () async {
      final downloader = _HoldingDownloader();
      final content = DbContentStore(store.db);
      final held = OfflineFiles(
        api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)),
        store: store,
        content: content,
        downloader: downloader,
      );
      await held.makeAvailableOffline("/Photos/a.jpg");
      await held.mirror();
      expect(downloader.enqueued, ["/Photos/a.jpg"]);

      downloader.finishQuietly("/Photos/a.jpg");
      await held.mirror();
      expect(downloader.enqueued, ["/Photos/a.jpg"]);

      final hash = await content.write(text("a"));
      downloader.report(ContentDownloadDone("/Photos/a.jpg", hash: hash));
      await held.whenDownloadsSettle();
      await held.mirror();

      expect(downloader.enqueued, ["/Photos/a.jpg"]);
      expect(utf8.decode((await held.read("/Photos/a.jpg"))!), "a");
      await held.dispose();
    });

    test("a download that cannot be queued does not stay marked as downloading", () async {
      final downloader = _HoldingDownloader()..refuse = StateError("server unreachable");
      final held = OfflineFiles(
        api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)),
        store: store,
        content: DbContentStore(store.db),
        downloader: downloader,
      );
      await held.makeAvailableOffline("/Photos");

      await expectLater(held.mirror(), throwsStateError);

      expect(held.activeDownloads, isEmpty);
      await held.dispose();
    });

    test("a download that finishes after it was removed from the device is not kept", () async {
      final downloader = _HoldingDownloader();
      final content = DbContentStore(store.db);
      final held = OfflineFiles(
        api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server)),
        store: store,
        content: content,
        downloader: downloader,
      );
      await held.makeAvailableOffline("/Photos");
      await held.mirror();
      await held.removeFromDevice("/Photos/a.jpg");

      downloader.report(ContentDownloadDone("/Photos/a.jpg", hash: await content.write(text("a"))));
      await pumpEventQueue();

      expect(await held.read("/Photos/a.jpg"), isNull);
      expect(downloader.enqueued, isNot(contains("/Photos/a.jpg")));
      await held.dispose();
    });

    test("a failed download is retried after a delay", () async {
      await files.makeAvailableOffline("/Photos");
      await files.mirror();
      server.unreachable = true;
      await files.whenDownloadsSettle();
      expect(files.failedDownloads, isNotEmpty);

      server.unreachable = false;
      final retryAt = await files.mirror();
      expect(retryAt, isNotNull);
      now = retryAt!;
      await files.mirror();
      await files.whenDownloadsSettle();

      expect(files.failedDownloads, isEmpty);
      expect(await localText("/Photos/a.jpg"), "a");
    });
  });

  group("local changes", () {
    setUp(() async {
      server.putFile("/Notes/Plan.md", utf8.encode("# Plan"));
      await files.pinNotes("/Notes");
      await sync();
    });

    test("an edit is saved on the device first and uploaded on the next sync", () async {
      await files.write("/Notes/Plan.md", text("# Plan, edited"));

      expect(await localText("/Notes/Plan.md"), "# Plan, edited");
      expect((await files.file("/Notes/Plan.md"))!.state, OfflineFileState.pending);
      expect(serverText("/Notes/Plan.md"), "# Plan");

      await sync();

      expect(serverText("/Notes/Plan.md"), "# Plan, edited");
      expect((await files.file("/Notes/Plan.md"))!.state, OfflineFileState.synced);
      expect(await outbox(), isEmpty);
    });

    test("repeated edits before a sync upload only once", () async {
      for (var i = 0; i < 5; i++) {
        await files.write("/Notes/Plan.md", text("# Plan $i"));
      }

      expect(await outbox(), hasLength(1));
      await sync();

      expect(serverText("/Notes/Plan.md"), "# Plan 4");
      expect(server.requests.where((request) => request == "PUT /files/content"), hasLength(1));
    });

    test("edits made while the server is unreachable stay on the device and sync once it is back", () async {
      server.unreachable = true;
      await files.write("/Notes/Plan.md", text("# Offline edit"));
      await files.write("/Notes/New.md", text("# Created offline"));

      final retryAt = await files.push();

      expect(retryAt, isNotNull);
      final failed = await files.file("/Notes/Plan.md");
      expect(failed!.state, OfflineFileState.failed);
      expect(failed.error!.kind, OutboxErrorKind.unreachable);
      expect(await localText("/Notes/Plan.md"), "# Offline edit");

      server.unreachable = false;
      now = retryAt!;
      await sync();

      expect(serverText("/Notes/Plan.md"), "# Offline edit");
      expect(serverText("/Notes/New.md"), "# Created offline");
      expect(await outbox(), isEmpty);
    });

    test("a server that cannot store keeps the change on the device and says why", () async {
      server.failWrites = (status: 507, code: "storage_full");
      await files.write("/Notes/Plan.md", text("# Disk is full"));

      await files.push();

      final failed = await files.file("/Notes/Plan.md");
      expect(failed!.error!.kind, OutboxErrorKind.storageFull);
      expect(failed.error!.kind.retries, isTrue);
      expect(await localText("/Notes/Plan.md"), "# Disk is full");

      server.failWrites = null;
      await files.retryNow();
      await sync();
      expect(serverText("/Notes/Plan.md"), "# Disk is full");
    });

    test("a write the server acknowledges but did not keep intact is not treated as synced", () async {
      server.corruptWrites = true;
      await files.write("/Notes/Plan.md", text("# This must arrive whole"));

      await files.push();

      final failed = await files.file("/Notes/Plan.md");
      expect(failed!.state, OfflineFileState.failed);
      expect(failed.error!.kind, OutboxErrorKind.serverDidNotStore);
      expect(await outbox(), hasLength(1));
    });

    test("an edit on both sides becomes a conflict that keeps both versions", () async {
      await files.write("/Notes/Plan.md", text("# Mine"));
      server.putFile("/Notes/Plan.md", utf8.encode("# Theirs"));

      await sync();

      final conflicted = await files.file("/Notes/Plan.md");
      expect(conflicted!.state, OfflineFileState.conflict);
      expect(conflicted.conflict!.server!.hash, isNotEmpty);
      expect(await localText("/Notes/Plan.md"), "# Mine");
      expect(serverText("/Notes/Plan.md"), "# Theirs");

      final copy = await files.resolve("/Notes/Plan.md", ConflictResolution.keepBoth);
      await sync();

      expect(copy, "/Notes/Plan (conflict).md");
      expect(serverText("/Notes/Plan.md"), "# Theirs");
      expect(serverText("/Notes/Plan (conflict).md"), "# Mine");
      expect(await localText("/Notes/Plan.md"), "# Theirs");
    });

    test("keeping mine in a conflict overwrites the server version", () async {
      await files.write("/Notes/Plan.md", text("# Mine"));
      server.putFile("/Notes/Plan.md", utf8.encode("# Theirs"));
      await sync();

      await files.resolve("/Notes/Plan.md", ConflictResolution.keepMine);
      await sync();

      expect(serverText("/Notes/Plan.md"), "# Mine");
      expect((await files.file("/Notes/Plan.md"))!.state, OfflineFileState.synced);
    });

    test("keeping the server version drops the local edit", () async {
      await files.write("/Notes/Plan.md", text("# Mine"));
      server.putFile("/Notes/Plan.md", utf8.encode("# Theirs"));
      await sync();

      await files.resolve("/Notes/Plan.md", ConflictResolution.keepServer);
      await sync();

      expect(await localText("/Notes/Plan.md"), "# Theirs");
      expect(await outbox(), isEmpty);
    });

    test("a retried create whose first attempt reached the server is not a conflict", () async {
      await files.write("/Notes/New.md", text("# New"));
      server.putFile("/Notes/New.md", utf8.encode("# New"));

      await sync();

      expect((await files.file("/Notes/New.md"))!.state, OfflineFileState.synced);
      expect(await outbox(), isEmpty);
    });

    test("a rename made offline keeps the file and its later edits", () async {
      await files.write("/Notes/Plan.md", text("# Plan, edited"));
      await files.move("/Notes/Plan.md", "/Notes/Roadmap.md");
      await files.write("/Notes/Roadmap.md", text("# Roadmap"));

      await sync();

      expect(server.contentOf("/Notes/Plan.md"), isNull);
      expect(serverText("/Notes/Roadmap.md"), "# Roadmap");
      expect(server.requests.where((request) => request == "POST /files/move"), hasLength(1));
    });

    test("a file created and renamed offline is uploaded once under its final name", () async {
      await files.write("/Notes/Draft.md", text("# Draft"));
      await files.move("/Notes/Draft.md", "/Notes/Final.md");

      await sync();

      expect(server.contentOf("/Notes/Draft.md"), isNull);
      expect(serverText("/Notes/Final.md"), "# Draft");
      expect(server.requests.where((request) => request == "POST /files/move"), isEmpty);
    });

    test("notes in new folders and deletions made offline reach the server", () async {
      await files.write("/Notes/Trips/Rome.md", text("# Rome"));
      await files.delete("/Notes/Plan.md");

      await sync();

      expect(server.nodes["/Notes/Trips"]!.isDir, isTrue);
      expect(serverText("/Notes/Trips/Rome.md"), "# Rome");
      expect(server.contentOf("/Notes/Plan.md"), isNull);
    });

    test("a file created and deleted offline never reaches the server", () async {
      await files.write("/Notes/Scratch.md", text("# Scratch"));
      await files.delete("/Notes/Scratch.md");

      await sync();

      expect(server.contentOf("/Notes/Scratch.md"), isNull);
      expect(await outbox(), isEmpty);
    });

    test("an edit to a file renamed elsewhere follows it to its new name", () async {
      await files.write("/Notes/Plan.md", text("# Plan, edited"));
      server.movePath("/Notes/Plan.md", "/Notes/Roadmap.md");

      await sync();
      await sync();

      expect(serverText("/Notes/Roadmap.md"), "# Plan, edited");
      expect(server.contentOf("/Notes/Plan.md"), isNull);
      expect(await files.file("/Notes/Plan.md"), isNull);
      expect((await files.file("/Notes/Roadmap.md"))!.state, OfflineFileState.synced);
    });

    test("a rejected change blocks only its own file", () async {
      await files.write("/Notes/Plan.md", text("# Mine"));
      server.putFile("/Notes/Plan.md", utf8.encode("# Theirs"));
      await files.write("/Notes/Other.md", text("# Other"));

      await sync();

      expect((await files.file("/Notes/Plan.md"))!.state, OfflineFileState.conflict);
      expect(serverText("/Notes/Other.md"), "# Other");
    });

    test("queued uploads outside pinned folders are forgotten once they reached the server", () async {
      await files.queueUpload("/Inbox/photo.jpg", Stream.value(text("jpeg")));

      await sync();

      expect(serverText("/Inbox/photo.jpg"), "jpeg");
      expect(await files.file("/Inbox/photo.jpg"), isNull);
    });

    test("a note edited outside pinned folders stays cached after it synced", () async {
      await files.write("/Elsewhere/Note.md", text("# One"));
      await sync();
      await files.write("/Elsewhere/Note.md", text("# Two"));
      await sync();

      expect(serverText("/Elsewhere/Note.md"), "# Two");
      expect((await files.file("/Elsewhere/Note.md"))!.state, OfflineFileState.synced);
    });

    test("garbage collection keeps queued content", () async {
      await files.write("/Notes/Plan.md", text("# Queued"));
      now = now.add(const Duration(hours: 1));

      await files.collectGarbage();

      expect(await localText("/Notes/Plan.md"), "# Queued");
    });
  });

  test("a download of unknown size counts no bytes and has no progress", () {
    const download = OfflineDownload(path: "/a.mp4", received: 500, total: -1);

    expect(download.countedBytes, 0);
    expect(download.progress, isNull);
  });

  test("received bytes never count beyond the file size", () {
    const download = OfflineDownload(path: "/a.mp4", received: 1200, total: 1000);

    expect(download.countedBytes, 1000);
    expect(download.progress, 1.0);
  });
}
