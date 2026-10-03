import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/services/sync/drift/drift_sync_state_store.dart";
import "package:nomad/services/sync/drift/sync_database.dart";
import "package:nomad/services/sync/in_memory_sync_state_store.dart";
import "package:nomad/services/sync/sync_state_store.dart";

import "../../support/fixtures.dart";

void main() {
  final stores = <String, SyncStateStore Function()>{
    "drift": () => DriftSyncStateStore(SyncDatabase(NativeDatabase.memory())),
    "in-memory": InMemorySyncStateStore.new,
  };

  for (final MapEntry(key: name, value: create) in stores.entries) {
    group(name, () {
      late SyncStateStore store;

      setUp(() => store = create());
      tearDown(() => store.close());

      test("round-trips roots", () async {
        const root = SyncRoot(id: "r1", accountId: "a", localPath: "/l", remotePath: "/r", mode: SyncMode.autoUpload);

        await store.saveRoot(root);
        await store.saveRoot(root.copyWith(enabled: false));

        expect(await store.roots(), [root.copyWith(enabled: false)]);
      });

      test("round-trips entries including their state", () async {
        final entry = syncedFile("docs/a.txt", state: EntryState.pinned).copyWith(syncRootId: "r1", manifestJson: "{}");

        await store.saveEntry(entry);

        expect((await store.entries("r1"))["docs/a.txt"], entry);
      });

      test("deletes a whole subtree but not siblings with a shared prefix", () async {
        for (final path in ["docs", "docs/a.txt", "docs/sub/b.txt", "docs2/c.txt"]) {
          await store.saveEntry(syncedFile(path).copyWith(syncRootId: "r1"));
        }

        await store.deleteEntryTree("r1", "docs");

        expect((await store.entries("r1")).keys, ["docs2/c.txt"]);
      });

      test("keeps a cursor per root and deleting a root clears its data", () async {
        await store.saveRoot(const SyncRoot(id: "r1", accountId: "a", localPath: "/l", remotePath: "/"));
        await store.saveCursor("r1", 42);
        await store.saveEntry(syncedFile("a.txt").copyWith(syncRootId: "r1"));

        expect(await store.cursor("r1"), 42);
        expect(await store.cursor("other"), 0);

        await store.deleteRoot("r1");

        expect(await store.cursor("r1"), 0);
        expect(await store.entries("r1"), isEmpty);
      });
    });
  }
}
