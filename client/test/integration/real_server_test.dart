@Tags(["integration"])
library;

import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:web_socket_channel/web_socket_channel.dart";

import "package:polder/models/activity.dart";
import "package:polder/models/server_event.dart";

import "package:polder/models/admin_user_requests.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/sync_entry.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/models/trash.dart";
import "package:polder/models/user.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/realtime/events_client.dart";
import "package:polder/services/sync/in_memory_sync_state_store.dart";
import "package:polder/services/sync/sync_engine.dart";

import "../support/random_bytes.dart";
import "../support/real_server.dart";

/// Runs the client against a real `polder` server, built from `POLDER_SERVER_DIR` or taken from `POLDER_SERVER_BIN`.
/// It skips itself when neither is set or Go is missing; `flutter test --exclude-tags integration` skips it too.
void main() {
  final unavailable = realServerUnavailableReason();
  if (unavailable != null) {
    test("real server", () {}, skip: unavailable);
    return;
  }
  late RealPolderServer server;
  late TokenPair adminTokens;
  late TokenPair userTokens;

  setUpAll(() async {
    server = await RealPolderServer.start();
    final anonymous = server.anonymousApi();
    expect((await anonymous.setupStatus()).needsSetup, isTrue);
    adminTokens = await anonymous.setup(username: "admin", password: "admin-password");
    final admin = server.signedIn(adminTokens).api;
    await admin.createUser(
      const CreateUserRequest(username: "alice", password: "alice-password", role: UserRole.user, quotaBytes: 0),
    );
    userTokens = await anonymous.login(username: "alice", password: "alice-password", deviceName: "Laptop");
  });

  tearDownAll(() => server.stop());

  group("api", () {
    test("setup, login, me and admin endpoints", () async {
      final anonymous = server.anonymousApi();
      final admin = server.signedIn(adminTokens).api;

      expect((await anonymous.setupStatus()).needsSetup, isFalse);
      await expectLater(anonymous.setup(username: "x", password: "password1"), throwsA(isA<ApiException>()));
      await expectLater(
        anonymous.login(username: "alice", password: "wrong", deviceName: "Laptop"),
        throwsA(isA<UnauthorizedException>()),
      );
      expect((await admin.me()).username, "admin");
      expect((await admin.listUsers()).map((user) => user.username), containsAll(["admin", "alice"]));
      await expectLater(server.signedIn(userTokens).api.listUsers(), throwsA(isA<ForbiddenException>()));
    });

    test("refresh rotates the refresh token and logout revokes it", () async {
      final anonymous = server.anonymousApi();
      final tokens = await anonymous.login(username: "alice", password: "alice-password", deviceName: "Phone");

      final rotated = await anonymous.refresh(tokens.refreshToken);
      await expectLater(anonymous.refresh(tokens.refreshToken), throwsA(isA<UnauthorizedException>()));
      await anonymous.logout(rotated.refreshToken);
      await expectLater(anonymous.refresh(rotated.refreshToken), throwsA(isA<UnauthorizedException>()));
    });

    test("a rejected access token is refreshed transparently", () async {
      final anonymous = server.anonymousApi();
      final tokens = await anonymous.login(username: "alice", password: "alice-password", deviceName: "Tablet");
      final client = server.signedIn(tokens.copyWith(accessToken: "expired"));

      expect((await client.api.me()).username, "alice");
      expect(client.session.tokens!.refreshToken, isNot(tokens.refreshToken));
    });

    test("files: put, list, stat, content, range, move, delete", () async {
      final api = server.signedIn(userTokens).api;
      final created = await api.putContent("/api/a.txt", Stream.value("hello".codeUnits), length: 5);
      final dir = await api.mkdir("/api/sub");

      expect(created.rev, greaterThan(0));
      expect(created.size, 5);
      expect(dir.isDir, isTrue);
      expect((await api.list("/api")).entries.map((entry) => entry.name), unorderedEquals(["a.txt", "sub"]));
      expect((await api.stat("/api/a.txt")).hash, created.hash);
      expect(String.fromCharCodes(await api.downloadBytes("/api/a.txt")), "hello");
      final range = await api.openContent("/api/a.txt", range: const ByteRange(1, 3), ifMatchRev: created.rev);
      expect(String.fromCharCodes(await range.expand((bytes) => bytes).toList()), "ell");

      final moved = await api.move(from: "/api/a.txt", to: "/api/sub/b.txt", baseRev: created.rev);
      await expectLater(api.stat("/api/a.txt"), throwsA(isA<NotFoundException>()));
      await expectLater(api.mkdir("/api/sub"), throwsA(isA<AlreadyExistsException>()));
      await api.delete("/api/sub/b.txt", baseRev: moved.rev);
      await expectLater(api.stat("/api/sub/b.txt"), throwsA(isA<NotFoundException>()));
      expect(await api.preview("/api/sub"), isNull);
    });

    test("a stale baseRev is a conflict carrying the current entry", () async {
      final api = server.signedIn(userTokens).api;
      final v1 = await api.putContent("/api/c.txt", Stream.value("v1".codeUnits), length: 2);
      final v2 = await api.putContent("/api/c.txt", Stream.value("v2".codeUnits), length: 2, baseRev: v1.rev);

      final error = await api
          .putContent("/api/c.txt", Stream.value("v3".codeUnits), length: 2, baseRev: v1.rev)
          .then<ConflictException?>((_) => null, onError: (Object error) => error as ConflictException);

      expect(error?.current?.rev, v2.rev);
      await expectLater(api.openContent("/api/c.txt", ifMatchRev: v1.rev), throwsA(isA<PreconditionFailedException>()));
    });

    test("writes over quota are rejected", () async {
      final admin = server.signedIn(adminTokens).api;
      await admin.createUser(
        const CreateUserRequest(username: "tiny", password: "tiny-password", role: UserRole.user, quotaBytes: 10),
      );
      final tiny = server.signedIn(
        await server.anonymousApi().login(username: "tiny", password: "tiny-password", deviceName: "Laptop"),
      );

      await expectLater(
        tiny.api.putContent("/big.bin", Stream.value(Uint8List(100)), length: 100),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test("deleted items can be restored, downloaded and deleted permanently", () async {
      final api = server.signedIn(userTokens).api;
      await api.putContent("/trash/notes.txt", Stream.value("old".codeUnits), length: 3);
      await api.delete("/trash/notes.txt");
      await api.putContent("/trash/notes.txt", Stream.value("new".codeUnits), length: 3);

      final item = (await api.listTrash()).items.singleWhere((item) => item.originalPath == "/trash/notes.txt");
      expect(String.fromCharCodes(await api.downloadFromTrash(item.id)), "old");
      await expectLater(api.restoreFromTrash(item.id), throwsA(isA<AlreadyExistsException>()));

      final kept = await api.restoreFromTrash(item.id, onConflict: RestoreMode.keepBoth);
      expect(kept.path, "/trash/notes (restored).txt");
      expect(String.fromCharCodes(await api.downloadBytes("/trash/notes.txt")), "new");

      await api.delete(kept.path);
      final trashed = (await api.listTrash()).items.firstWhere((item) => item.originalPath == kept.path);
      await api.deleteFromTrash(trashed.id);
      await expectLater(api.restoreFromTrash(trashed.id), throwsA(isA<NotFoundException>()));
    });

    test("the server's trash retention is the most a user can choose", () async {
      final admin = server.signedIn(adminTokens).api;
      final api = server.signedIn(userTokens).api;

      await admin.updateServerSettings(trashRetentionDays: 30);
      await expectLater(
        api.setTrashRetention(const TrashPreferences(days: 60)),
        throwsA(isA<InvalidRequestException>()),
      );
      expect((await api.setTrashRetention(const TrashPreferences(days: 7))).days, 7);
      await admin.updateServerSettings(trashRetentionDays: 5);
      expect((await api.trashRetention()).days, 5);

      final off = await api.setTrashRetention(const TrashPreferences(enabled: false));
      expect((off.enabled, off.serverEnabled), (false, true));
      expect((await api.setTrashRetention(const TrashPreferences())).source, RetentionSource.serverDefault);
    });
  });

  group("sync engine", () {
    late Directory localRoot;
    late PolderApi otherDevice;
    late TransferCounter counter;
    late InMemorySyncStateStore store;
    late SyncEngine engine;
    late SyncRoot root;
    var testIndex = 0;

    File local(String relativePath) => File("${localRoot.path}/$relativePath");

    Future<Uint8List> remote(String relativePath) => otherDevice.downloadBytes("${root.remotePath}/$relativePath");

    Future<void> putRemote(String relativePath, List<int> bytes) => otherDevice.putContent(
      "${root.remotePath}/$relativePath",
      Stream.value(bytes),
      length: bytes.length,
      baseRev: -1,
    );

    setUp(() async {
      localRoot = await Directory.systemTemp.createTemp("polder_sync");
      final device = server.signedIn(userTokens);
      counter = device.counter;
      otherDevice = server.signedIn(userTokens).api;
      store = InMemorySyncStateStore();
      engine = SyncEngine(
        api: device.api,
        store: store,
        deviceName: "Laptop",
        clock: () => DateTime(2026, 9, 30, 14, 5),
      );
      root = SyncRoot(id: "root", accountId: "a", localPath: localRoot.path, remotePath: "/sync${testIndex++}");
      await otherDevice.mkdir(root.remotePath);
    });

    tearDown(() => localRoot.delete(recursive: true));

    test("first sync downloads the remote tree and records it", () async {
      final big = randomBytes(1500000);
      await putRemote("a.txt", "hello".codeUnits);
      await putRemote("sub/big.bin", big);

      final report = await engine.run(root);

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(await local("a.txt").readAsString(), "hello");
      expect(await local("sub/big.bin").readAsBytes(), big);
      final entries = await store.entries("root");
      expect(entries.keys, containsAll(["a.txt", "sub", "sub/big.bin"]));
      expect(entries["sub/big.bin"]!.state, EntryState.hydrated);
    });

    test("new local files are uploaded and a second run is a no-op", () async {
      await local("notes.txt").writeAsString("local notes");
      await Directory("${localRoot.path}/photos").create();
      final photo = randomBytes(600000);
      await local("photos/p.jpg").writeAsBytes(photo);

      final first = await engine.run(root);
      final second = await engine.run(root);

      expect(first.hasFailures, isFalse, reason: first.errors.join("\n"));
      expect(first.uploaded, 3);
      expect(String.fromCharCodes(await remote("notes.txt")), "local notes");
      expect(await remote("photos/p.jpg"), photo);
      expect(second.uploaded + second.downloaded + second.deleted, 0, reason: second.errors.join("\n"));
    });

    test("a small local edit to a large file uploads only the changed chunks", () async {
      final original = randomBytes(6 * 1024 * 1024);
      await putRemote("video.bin", original);
      await engine.run(root);
      final edited = Uint8List.fromList(original)..setRange(3000000, 3000010, List.filled(10, 7));
      await local("video.bin").writeAsBytes(edited);
      counter.reset();

      final report = await engine.run(root);

      expect(report.uploaded, 1, reason: report.errors.join("\n"));
      expect(await remote("video.bin"), edited);
      expect(counter.chunkBytesSent, inExclusiveRange(0, original.length ~/ 2));
    });

    test("a small remote edit to a large file downloads only the changed ranges", () async {
      final original = randomBytes(6 * 1024 * 1024);
      await putRemote("video.bin", original);
      await engine.run(root);
      final edited = Uint8List.fromList(original)..setRange(100, 110, List.filled(10, 9));
      await putRemote("video.bin", edited);
      counter.reset();

      final report = await engine.run(root);

      expect(report.downloaded, 1, reason: report.errors.join("\n"));
      expect(await local("video.bin").readAsBytes(), edited);
      expect(counter.rangeBytesReceived, inExclusiveRange(0, original.length ~/ 2));
    });

    test("deletes propagate in both directions", () async {
      await putRemote("remote-gone.txt", "a".codeUnits);
      await putRemote("local-gone.txt", "b".codeUnits);
      await engine.run(root);
      await otherDevice.delete("${root.remotePath}/remote-gone.txt");
      await local("local-gone.txt").delete();

      final report = await engine.run(root);

      expect(report.deleted, 2, reason: report.errors.join("\n"));
      expect(await local("remote-gone.txt").exists(), isFalse);
      await expectLater(remote("local-gone.txt"), throwsA(isA<NotFoundException>()));
    });

    test("a remote directory delete removes the local subtree", () async {
      await putRemote("dir/nested/x.txt", "x".codeUnits);
      await engine.run(root);
      await otherDevice.delete("${root.remotePath}/dir");

      final report = await engine.run(root);

      expect(report.hasFailures, isFalse, reason: report.errors.join("\n"));
      expect(await Directory("${localRoot.path}/dir").exists(), isFalse);
    });

    test("remote renames and moves into another sync root move local files", () async {
      final otherLocalRoot = await Directory.systemTemp.createTemp("polder_sync_other");
      addTearDown(() => otherLocalRoot.delete(recursive: true));
      final otherRoot = SyncRoot(
        id: "other",
        accountId: "a",
        localPath: otherLocalRoot.path,
        remotePath: "${root.remotePath}-other",
      );
      await otherDevice.mkdir(otherRoot.remotePath);
      await store.saveRoot(root);
      await store.saveRoot(otherRoot);
      await putRemote("old/a.txt", "a".codeUnits);
      await putRemote("b.txt", "b".codeUnits);
      await engine.run(root);
      await engine.run(otherRoot);
      await otherDevice.move(from: "${root.remotePath}/old", to: "${root.remotePath}/new");
      await otherDevice.move(from: "${root.remotePath}/b.txt", to: "${otherRoot.remotePath}/b.txt");

      final report = await engine.run(root);
      final otherReport = await engine.run(otherRoot);

      expect(report.moved, 2, reason: report.errors.join("\n"));
      expect(report.downloaded + otherReport.downloaded, 0);
      expect(await local("new/a.txt").readAsString(), "a");
      expect(await Directory("${localRoot.path}/old").exists(), isFalse);
      expect(await local("b.txt").exists(), isFalse);
      expect(await File("${otherLocalRoot.path}/b.txt").readAsString(), "b");
    });

    test("changes on both sides become a conflict that keep both resolves", () async {
      await putRemote("report.txt", "v1".codeUnits);
      await engine.run(root);
      await local("report.txt").writeAsString("mine");
      await putRemote("report.txt", "theirs".codeUnits);

      final report = await engine.run(root);
      final conflict = report.conflicts.single;
      await engine.resolve(root, conflict, ConflictResolution.keepBoth);

      expect(conflict.kind, ConflictKind.bothModified);
      const copyName = "report (conflict Laptop 2026-09-30 1405).txt";
      expect(await local("report.txt").readAsString(), "theirs");
      expect(await local(copyName).readAsString(), "mine");
      expect(String.fromCharCodes(await remote(copyName)), "mine");
      expect((await engine.run(root)).conflicts, isEmpty);
    });

    test("keep mine overwrites the server version against its current rev", () async {
      await putRemote("report.txt", "v1".codeUnits);
      await engine.run(root);
      await local("report.txt").writeAsString("mine");
      await putRemote("report.txt", "theirs".codeUnits);
      final conflict = (await engine.run(root)).conflicts.single;

      await engine.resolve(root, conflict, ConflictResolution.keepMine);

      expect(String.fromCharCodes(await remote("report.txt")), "mine");
    });

    test("keep server's after a remote delete removes the local file", () async {
      await putRemote("report.txt", "v1".codeUnits);
      await engine.run(root);
      await local("report.txt").writeAsString("mine");
      await otherDevice.delete("${root.remotePath}/report.txt");
      final conflict = (await engine.run(root)).conflicts.single;

      await engine.resolve(root, conflict, ConflictResolution.keepServer);

      expect(conflict.kind, ConflictKind.localModifiedRemoteDeleted);
      expect(await local("report.txt").exists(), isFalse);
    });

    test("auto-upload mode only uploads", () async {
      final uploadRoot = root.copyWith(mode: SyncMode.autoUpload);
      await putRemote("remote.jpg", "r".codeUnits);
      await local("camera.jpg").writeAsBytes(randomBytes(1000));

      final report = await engine.run(uploadRoot);
      await local("camera.jpg").delete();
      await engine.run(uploadRoot);

      expect(report.uploaded, 1, reason: report.errors.join("\n"));
      expect(await local("remote.jpg").exists(), isFalse);
      expect(await remote("camera.jpg"), isNotEmpty);
    });
  });

  group("live activity", () {
    test("an upload streams over the events socket and lands in the activity log", () async {
      final alice = server.signedIn(userTokens).api;
      final events = EventsClient(
        endpoint: EventsClient.endpointFor(server.url),
        token: ({required refresh}) async => userTokens.accessToken,
        connect: WebSocketChannel.connect,
      );
      addTearDown(events.dispose);
      final received = <ServerEvent>[];
      final snapshot = Completer<void>();
      final logged = Completer<ActivityEntry>();
      events.events.listen((event) {
        received.add(event);
        if (event is SnapshotEvent && !snapshot.isCompleted) snapshot.complete();
        if (event case ActivityCreatedEvent(:final entry) when entry.path == "/Live/upload.bin") logged.complete(entry);
      });
      events.start();
      await snapshot.future.timeout(const Duration(seconds: 10));

      final content = Uint8List(1 << 20);
      await alice.putContent("/Live/upload.bin", Stream.value(content), length: content.length, transferId: "local-42");
      final entry = await logged.future.timeout(const Duration(seconds: 10));

      expect(entry.kind, ActivityKind.upload);
      expect(entry.bytes, content.length);
      expect(entry.device, "Laptop");
      final started = received.whereType<TransferEvent>().firstWhere((event) => event.phase == TransferPhase.started);
      expect(started.transfer.clientId, "local-42");
      expect(started.transfer.total, content.length);
      expect(received.whereType<FilesChangedEvent>().expand((event) => event.dirs), containsAll(["/", "/Live"]));

      final page = await alice.activity(scope: const ActivityScope.me());
      expect(page.entries.first.id, entry.id);
    });
  });
}
