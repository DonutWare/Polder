import "package:flutter_test/flutter_test.dart";
import "package:polder/models/activity.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/server_event.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/activity/now_groups_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/providers/realtime/directory_refresher_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/wire_mappers.dart";
import "package:polder/services/sync/sync_activity.dart";

import "../support/fake_web_socket.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

LiveTransfer _transfer(String id, String path, {int userId = 1, String? clientId}) =>
    wire.LiveTransfer.fromJson(transferJson(id: id, path: path, userId: userId, clientId: clientId)).toModel();

FileEntry _file(String name, {bool isDir = false}) =>
    FileEntry(path: "/$name", name: name, isDir: isDir, mtime: DateTime.utc(2026));

void main() {
  group("live transfers", () {
    late ProviderHarness harness;
    setUp(() async {
      harness = ProviderHarness(account: testAccount());
      await harness.container.read(accountProvider.future);
    });
    tearDown(() => harness.dispose());

    LiveTransfersNotifier notifier() => harness.container.read(liveTransfersProvider.notifier);

    test("follow snapshots, progress and completion", () {
      notifier().apply(SnapshotEvent([_transfer("a", "/Photos/a.jpg"), _transfer("b", "/b.bin", userId: 2)]));
      expect(harness.container.read(scopedTransfersProvider).map((t) => t.id), ["a"]);

      harness.container.read(activityScopeProvider.notifier).select(const ActivityScope.all());
      expect(harness.container.read(scopedTransfersProvider).map((t) => t.id), ["a", "b"]);

      notifier().apply(TransferEvent(TransferPhase.progress, _transfer("a", "/Photos/a.jpg").copyWith(bytes: 50)));
      expect(harness.container.read(liveTransfersProvider)["a"]!.progress, 0.5);

      notifier().apply(TransferEvent(TransferPhase.finished, _transfer("a", "/Photos/a.jpg")));
      notifier().apply(const DisconnectedEvent());
      expect(harness.container.read(liveTransfersProvider), isEmpty);
    });

    test("only your own uploads show up in folders", () {
      notifier().apply(
        SnapshotEvent([
          _transfer("a", "/Photos/2026/a.jpg"),
          _transfer("b", "/Photos/b.jpg"),
          _transfer("c", "/Photos/c.jpg", userId: 2),
        ]),
      );
      expect(harness.container.read(uploadsIntoDirectoryProvider("/Photos")).map((t) => t.id), ["b"]);
      expect(harness.container.read(busyFoldersProvider("/")), {"Photos"});
      expect(harness.container.read(busyFoldersProvider("/Photos")), {"2026"});
    });
  });

  group("now groups", () {
    late ProviderHarness harness;
    setUp(() async {
      harness = ProviderHarness(account: testAccount());
      await harness.container.read(accountProvider.future);
      harness.container.listen(nowGroupsProvider, (_, _) {});
    });
    tearDown(() => harness.dispose());

    const root = SyncRoot(id: "r", accountId: "a", localPath: "/local", remotePath: "/Docs");

    Future<Map<String, NowGroup>> groups() async {
      await pumpEventQueue();
      return {for (final group in harness.container.read(nowGroupsProvider)) group.folder: group};
    }

    test("a batch stays one group while it finishes, counting what is done", () async {
      final activity = harness.container.read(syncActivityProvider);
      activity.enqueue(root, [for (var i = 0; i < 5; i++) "Trip/day$i/photo.jpg"]);
      for (var i = 1; i < 5; i++) {
        activity.done(root.id, "Trip/day$i/photo.jpg");
      }

      final trip = (await groups())["/Docs/Trip"]!;

      expect(trip.isBatch, isTrue);
      expect((trip.active, trip.completed, trip.totalFiles), (1, 4, 5));
    });

    test("two files in a folder are a batch, a lone file is not", () async {
      harness.container.read(syncActivityProvider)
        ..enqueue(root, ["Trip/a.jpg", "Trip/sub/b.jpg"])
        ..begin(root, "notes.txt", LocalSyncPhase.preparing);

      final all = await groups();

      expect(all["/Docs/Trip"]!.isBatch, isTrue);
      expect(all["/Docs"]!.isBatch, isFalse);
    });

    test("transfers the server reports group by folder and count what finished", () async {
      final transfers = harness.container.read(liveTransfersProvider.notifier);
      final started = [for (var i = 0; i < 3; i++) _transfer("t$i", "/Photos/p$i.jpg", userId: 2)];
      harness.container.read(activityScopeProvider.notifier).select(const ActivityScope.all());
      transfers.apply(SnapshotEvent(started));
      transfers
        ..apply(TransferEvent(TransferPhase.finished, started[0]))
        ..apply(TransferEvent(TransferPhase.finished, started[1]));

      final photos = (await groups())["/Photos"]!;
      expect(photos.isBatch, isTrue);
      expect((photos.active, photos.completed), (1, 2));

      transfers.apply(TransferEvent(TransferPhase.finished, started[2]));
      expect(await groups(), isEmpty);
      expect(transfers.finishedByFolder, isEmpty);
    });
  });

  group("pending uploads", () {
    const upload = PendingUpload(path: "/b.txt", bytes: 1);

    test("sit among the files by name, after the folders", () {
      final items = mergePendingUploads(
        [_file("Zeta", isDir: true), _file("a.txt"), _file("c.txt")],
        [upload, const PendingUpload(path: "/A.txt", bytes: 0)],
      );
      expect(items.map((item) => item.name), ["Zeta", "a.txt", "A.txt", "b.txt", "c.txt"]);
      expect(items[3].entry, isNull);
    });

    test("folders still on their way show up among the folders", () {
      final items = mergePendingUploads([_file("Alpha", isDir: true), _file("a.txt")], [], busyFolders: {"Beta"});
      expect(items.map((item) => item.name), ["Alpha", "Beta", "a.txt"]);
      expect(items[1].pendingFolder, "Beta");
    });

    test("lie over the file they replace", () {
      final items = mergePendingUploads([_file("b.txt")], [upload], busyFolders: {"b.txt"});
      expect(items.single.entry?.name, "b.txt");
      expect(items.single.pending, same(upload));
      expect(items.single.busy, isFalse);
    });
  });

  test("open folders reload when the server reports a change in them", () async {
    final socket = FakeWebSocket();
    final listed = <String>[];
    final harness = ProviderHarness(
      account: testAccount(),
      webSocketConnector: (_) => socket,
      httpClient: ScriptedClient((request) async {
        if (request.path == "/auth/me") return jsonResponse(200, userJson());
        listed.add(request.query["path"]!);
        return jsonResponse(200, {"path": request.query["path"], "entries": <Object>[], "indexing": false});
      }),
    );
    addTearDown(harness.dispose);
    await harness.container.read(accountProvider.future);
    harness.container.listen(directoryProvider("/Photos"), (_, _) {});
    harness.container.listen(directoryRefresherProvider, (_, _) {});
    await harness.container.read(directoryProvider("/Photos").future);
    await pumpEventQueue();

    socket.serverSends({
      "type": "files.changed",
      "userId": 2,
      "dirs": ["/Photos"],
    });
    for (var i = 0; i < 3; i++) {
      socket.serverSends({
        "type": "files.changed",
        "userId": 1,
        "dirs": ["/", "/Photos"],
      });
    }
    await Future<void>.delayed(DirectoryRefresher.debounce * 2);

    expect(listed, ["/Photos", "/Photos"]);
  });
}
