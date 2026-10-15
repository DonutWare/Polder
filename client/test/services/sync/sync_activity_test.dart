import "dart:async";
import "dart:io";
import "dart:math";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/sync/sync_root.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/chunker.dart";
import "package:polder/services/sync/in_memory_sync_state_store.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_engine.dart";

import "../../support/fake_server.dart";
import "../../support/random_bytes.dart";

void main() {
  late Directory localRoot;
  late SyncRoot root;
  late SyncActivity activity;

  File local(String relativePath) => File("${localRoot.path}/$relativePath");

  setUp(() async {
    localRoot = await Directory.systemTemp.createTemp("polder_activity");
    root = SyncRoot(id: "root", accountId: "a", localPath: localRoot.path, remotePath: "/Docs");
    activity = SyncActivity();
  });

  tearDown(() async {
    activity.dispose();
    await localRoot.delete(recursive: true);
  });

  group("noticing changes", () {
    test("a new file waits right away, and leaves when it is removed", () async {
      await local("report.pdf").writeAsString("draft");

      await activity.observe(root, local("report.pdf").path);
      final item = activity.items.values.single;
      expect(item.remotePath, "/Docs/report.pdf");
      expect(item.phase, LocalSyncPhase.waiting);

      await local("report.pdf").delete();
      await activity.observe(root, local("report.pdf").path);
      expect(activity.items, isEmpty);
    });

    test("a folder dropped in brings its files along, without temp or system files", () async {
      await Directory("${localRoot.path}/Trip/day1").create(recursive: true);
      await local("Trip/day1/a.jpg").writeAsString("a");
      await local("Trip/.DS_Store").writeAsString("x");
      await local("Trip/.polder-123-b.jpg").writeAsString("partial");

      await activity.observe(root, "${localRoot.path}/Trip");

      expect(activity.items.values.map((item) => item.relativePath), ["Trip/day1/a.jpg"]);
    });

    test("removing a file cancels the work in progress on it, and on what was inside a folder", () async {
      final file = activity.begin(root, "a.bin", LocalSyncPhase.preparing, total: 10);
      final nested = activity.begin(root, "Trip/b.bin", LocalSyncPhase.uploading, total: 10);

      activity
        ..vanished(root.id, "a.bin")
        ..vanished(root.id, "Trip");

      expect(file.isCancelled, isTrue);
      expect(nested.isCancelled, isTrue);
      expect(activity.items, isEmpty);
    });

    test("a file that changes again mid-upload cancels the stale upload and waits again", () async {
      await local("a.bin").writeAsString("one");
      final upload = activity.begin(root, "a.bin", LocalSyncPhase.uploading, total: 3);

      await activity.observe(root, local("a.bin").path);

      expect(upload.isCancelled, isTrue);
      expect(activity.items.values.single.phase, LocalSyncPhase.waiting);
    });

    test("this device's own downloads are not mistaken for new files", () async {
      activity.expectWrite(root.id, "from-server.txt");
      await local("from-server.txt").writeAsString("downloaded");

      await activity.observe(root, local("from-server.txt").path);

      expect(activity.items, isEmpty);
    });

    test("settling after a run keeps only what changed during it", () async {
      var now = DateTime(2026, 10, 4, 12);
      activity = SyncActivity(clock: () => now);
      await local("old.txt").writeAsString("old");
      await local("new.txt").writeAsString("new");
      await activity.observe(root, local("old.txt").path);
      activity.begin(root, "found-by-scan.bin", LocalSyncPhase.preparing);

      final runStartedAt = now = now.add(const Duration(seconds: 1));
      now = now.add(const Duration(seconds: 1));
      await activity.observe(root, local("new.txt").path);
      activity.settle(root.id, runStartedAt);

      expect(activity.items.values.map((item) => item.relativePath), ["new.txt"]);
    });
  });

  group("tracked chunking", () {
    test("reports progress and matches the plain manifest", () async {
      final file = local("big.bin");
      await file.writeAsBytes(randomBytes(20 * 1024 * 1024));
      final progress = <int>[];

      final manifest = await FastCdc.manifestOfFileTracked(file, onProgress: progress.add, cancel: CancelToken());

      expect(manifest, await FastCdc.manifestOfFile(file));
      expect(progress, isNotEmpty);
      expect(progress, orderedEquals([...progress]..sort()));
    });

    test("cancelling stops it", () async {
      final file = local("big.bin");
      await file.writeAsBytes(randomBytes(64 * 1024 * 1024));
      final cancel = CancelToken();

      final chunking = FastCdc.manifestOfFileTracked(file, onProgress: (_) => cancel.cancel(), cancel: cancel);

      await expectLater(chunking, throwsA(isA<SyncCancelledException>()));
    });
  });

  group("sync runs", () {
    late FakePolderServer server;
    late InMemorySyncStateStore store;
    late SyncEngine engine;

    setUp(() {
      server = FakePolderServer();
      store = InMemorySyncStateStore();
      final api = PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: server));
      engine = SyncEngine(api: api, store: store, deviceName: "Laptop", activity: activity);
    });

    test("remote files are listed as downloads in their folder and count as done once stored", () async {
      for (var i = 0; i < 5; i++) {
        server.putFile("/Docs/Trip/photo$i.jpg", randomBytes(1000, seed: i));
      }
      final seen = <LocalSyncItem>[];
      final subscription = activity.changes.listen((items) => seen.addAll(items.values));
      addTearDown(subscription.cancel);

      final report = await engine.run(root);

      expect(report.downloaded, 6, reason: report.errors.join("\n"));
      expect(
        seen.where((item) => item.relativePath.startsWith("Trip/")),
        everyElement(isA<LocalSyncItem>().having((item) => item.isDownload, "isDownload", isTrue)),
      );
      expect(seen.map((item) => item.group).toSet(), {"root:Trip"});
      expect(activity.items, isEmpty);
    });

    test("a big file only moves forward through its phases until it is done", () async {
      final content = randomBytes(6 * 1024 * 1024);
      await local("video.bin").writeAsBytes(content);
      final phases = <LocalSyncPhase>[];
      final subscription = activity.changes.listen((items) {
        final phase = items["root:video.bin"]?.phase;
        if (phase != null && (phases.isEmpty || phases.last != phase)) phases.add(phase);
      });
      addTearDown(subscription.cancel);

      final report = await engine.run(root);

      expect(report.uploaded, 1, reason: report.errors.join("\n"));
      expect(server.contentOf("/Docs/video.bin"), content);
      expect(phases.first, LocalSyncPhase.waiting);
      expect(phases, [...phases]..sort((a, b) => a.index.compareTo(b.index)));
      expect(activity.items, isEmpty);
    });

    test("a file removed while it is being prepared is skipped, not uploaded or failed", () async {
      await local("keep.txt").writeAsString("keep");
      await local("oops.bin").writeAsBytes(randomBytes(48 * 1024 * 1024));
      final subscription = activity.changes.listen((items) {
        if (items["root:oops.bin"]?.phase != LocalSyncPhase.preparing) return;
        local("oops.bin").deleteSync();
        activity.vanished(root.id, "oops.bin");
      });
      addTearDown(subscription.cancel);

      final report = await engine.run(root);

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(report.deferred, 1);
      expect(server.contentOf("/Docs/oops.bin"), isNull);
      expect(server.contentOf("/Docs/keep.txt"), isNotNull);
      expect(await store.cursor("root"), 0, reason: "the feed is read again while something is deferred");
      expect(activity.items, isEmpty);

      final next = await engine.run(root);
      expect(next.deferred + next.uploaded + next.deleted + next.failed, 0);
    });
  });

  group("pipelined runs", () {
    late FakePolderServer server;
    late InMemorySyncStateStore store;
    late SyncEngine engine;
    void Function() onChunk = () {};

    setUp(() async {
      server = FakePolderServer();
      store = InMemorySyncStateStore();
      onChunk = () {};
      final client = _ChunkWatcher(server, () => onChunk());
      final api = PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: client));
      engine = SyncEngine(api: api, store: store, deviceName: "Laptop", activity: activity);
      await Directory("${localRoot.path}/Trip").create();
      for (var i = 0; i < 10; i++) {
        await local("Trip/photo$i.jpg").writeAsBytes(randomBytes(3 * 1024 * 1024, seed: i));
      }
    });

    test("new folders exist on the server before hashing, and uploads start while hashing goes on", () async {
      bool? folderBeforeHashing;
      var preparingAfterFirstUpload = false;
      final subscription = activity.changes.listen((items) {
        final preparing = items.values.where((item) => item.phase == LocalSyncPhase.preparing);
        if (preparing.isEmpty) return;
        folderBeforeHashing ??= server.nodes["/Docs/Trip"]?.isDir ?? false;
        if (server.requests.contains("POST /sync/batches")) preparingAfterFirstUpload = true;
      });
      addTearDown(subscription.cancel);

      final report = await engine.run(root);

      expect(report.uploaded, 11, reason: report.errors.join("\n"));
      expect(folderBeforeHashing, isTrue);
      expect(preparingAfterFirstUpload, isTrue);
      expect(activity.items, isEmpty);
    });

    test("the whole batch is listed at once", () async {
      var mostListed = 0;
      final subscription = activity.changes.listen((items) => mostListed = max(mostListed, items.length));
      addTearDown(subscription.cancel);

      await engine.run(root);

      expect(mostListed, 10);
    });

    test("stopping a sync folder ends its run at once and aborts the upload in flight", () async {
      onChunk = () {
        activity.cancelRoot(root.id, CancelReason.stopped);
      };

      final report = await engine.run(root);

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(report.deferred, greaterThan(0));
      expect(report.uploaded, lessThan(11));
      expect(server.batches, isEmpty, reason: "the interrupted upload is aborted");
      expect(activity.items, isEmpty);
    });

    test("pausing keeps a partly sent upload, and resuming sends only what is missing", () async {
      final big = randomBytes(16 * 1024 * 1024, seed: 99);
      await Directory("${localRoot.path}/Trip").delete(recursive: true);
      await local("movie.bin").writeAsBytes(big);
      var chunks = 0;
      onChunk = () {
        if (++chunks == 2) activity.cancelAll(CancelReason.paused);
      };

      final paused = await engine.run(root);
      expect(paused.hasFailures, isFalse, reason: paused.errors.join("\n"));
      expect(paused.deferred, 1);
      expect(server.batches, hasLength(1), reason: "the server keeps the batch for later");
      expect(activity.items.values.single.phase, LocalSyncPhase.waiting);
      final sentBeforePause = server.chunkBytesReceived;

      onChunk = () {};
      final resumed = await engine.run(root);

      expect(resumed.uploaded, 1, reason: resumed.errors.join("\n"));
      expect(server.contentOf("/Docs/movie.bin"), big);
      expect(server.chunkBytesReceived, big.length, reason: "no chunk is sent twice");
      expect(sentBeforePause, greaterThan(0));
      expect(activity.items, isEmpty);
    });
  });

  group("interrupting work in flight", () {
    late FakePolderServer server;
    late InMemorySyncStateStore store;
    late SyncEngine engine;
    late Completer<void> network;
    late void Function(http.BaseRequest request) onRequest;

    setUp(() {
      server = FakePolderServer();
      store = InMemorySyncStateStore();
      network = Completer<void>();
      onRequest = (_) {};
      final client = _StallingClient(server, (request) => onRequest(request), network.future);
      engine = SyncEngine(
        api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: client)),
        store: store,
        deviceName: "Laptop",
        activity: activity,
      );
    });

    tearDown(() {
      if (!network.isCompleted) network.complete();
    });

    test("pausing does not wait for a chunk stuck on the network", () async {
      await local("movie.bin").writeAsBytes(randomBytes(8 * 1024 * 1024));
      onRequest = (request) {
        if (request.url.path.endsWith("/stream")) activity.cancelAll(CancelReason.paused);
      };

      final report = await engine.run(root).timeout(const Duration(seconds: 5));

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(report.deferred, 1);
      expect(activity.items.values.single.phase, LocalSyncPhase.waiting);
    });

    test("stopping does not wait for a download stuck on the network, and leaves nothing behind", () async {
      server.putFile("/Docs/big.iso", randomBytes(6 * 1024 * 1024));
      onRequest = (request) {
        if (request.url.path.endsWith("/files/content")) activity.cancelRoot(root.id, CancelReason.stopped);
      };

      final report = await engine.run(root).timeout(const Duration(seconds: 5));

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(report.deferred, 1);
      expect(localRoot.listSync(), isEmpty, reason: "neither the file nor its temp file is left");
    });
  });

  group("speed", () {
    test("uploads add up per batch and overall, while preparing does not count", () {
      var now = DateTime(2026);
      final timed = SyncActivity(clock: () => now);
      addTearDown(timed.dispose);
      timed
        ..enqueue(root, ["Trip/a.jpg", "Trip/b.jpg", "c.txt"])
        ..begin(root, "Trip/a.jpg", LocalSyncPhase.uploading, total: 4000)
        ..begin(root, "Trip/b.jpg", LocalSyncPhase.uploading, total: 4000)
        ..begin(root, "c.txt", LocalSyncPhase.preparing, total: 4000)
        ..progress(root.id, "Trip/a.jpg", 1000)
        ..progress(root.id, "Trip/b.jpg", 1000)
        ..progress(root.id, "c.txt", 4000)
        ..done(root.id, "Trip/a.jpg");
      now = now.add(const Duration(milliseconds: 500));

      expect(timed.uploadRate, 2000);
      expect(timed.groupRate("root:Trip"), 2000);
      expect(timed.groupRate("root:"), 0);
    });

    test("downloaded bytes feed the download rate", () {
      final timed = SyncActivity(clock: () => DateTime(2026));
      addTearDown(timed.dispose);

      timed
        ..downloaded(300)
        ..downloaded(700);

      expect(timed.downloadRate, 1000);
      expect(timed.uploadRate, 0);
    });
  });
}

class _ChunkWatcher extends http.BaseClient {
  _ChunkWatcher(this._server, this._onChunk);

  final FakePolderServer _server;
  final void Function() _onChunk;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (!request.url.path.endsWith("/stream")) return _server.send(request);
    final watched = http.StreamedRequest(request.method, request.url)
      ..headers.addAll(request.headers)
      ..contentLength = request.contentLength;
    request
        .finalize()
        .map((chunk) {
          _onChunk();
          return chunk;
        })
        .listen(watched.sink.add, onError: watched.sink.addError, onDone: watched.sink.close);
    return _server.send(watched);
  }
}

class _StallingClient extends http.BaseClient {
  _StallingClient(this._server, this._onRequest, this._network);

  final FakePolderServer _server;
  final void Function(http.BaseRequest request) _onRequest;
  final Future<void> _network;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stalls = request.url.path.endsWith("/stream") || request.url.path.endsWith("/files/content");
    _onRequest(request);
    if (stalls) await _network;
    return _server.send(request);
  }
}
