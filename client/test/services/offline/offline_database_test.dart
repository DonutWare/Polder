import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/services/offline/offline_store.dart";

void main() {
  test("upgrading from the first version keeps unsynced files and fills the new columns", () async {
    void seed(dynamic raw) => raw
      ..execute(
        "CREATE TABLE files (path TEXT PRIMARY KEY NOT NULL, parent TEXT NOT NULL, state TEXT NOT NULL, json TEXT NOT NULL)",
      )
      ..execute(
        "INSERT INTO files VALUES ('/Notes/Plan.md', '/Notes', 'pending', "
        "'{\"entry\":{\"path\":\"/Notes/Plan.md\",\"name\":\"Plan.md\",\"size\":12,\"mtime\":\"2026-11-10T12:00:00.000Z\",\"hash\":\"old\"},\"localHash\":\"new\",\"state\":\"pending\"}')",
      )
      ..execute(
        "INSERT INTO files VALUES ('/Photos/a.jpg', '/Photos', 'synced', "
        "'{\"entry\":{\"path\":\"/Photos/a.jpg\",\"name\":\"a.jpg\",\"size\":5,\"mtime\":\"2026-11-10T12:00:00.000Z\",\"hash\":\"h\"}}')",
      )
      ..userVersion = 1;
    final store = OfflineStore(OfflineDatabase(NativeDatabase.memory(setup: seed)));

    final note = await store.file("/Notes/Plan.md");
    final counts = await store.counts("/");

    expect(note!.state, OfflineFileState.pending);
    expect(note.localHash, "new");
    expect(counts, (files: 2, ready: 1, bytes: 17, readyBytes: 12));
    await store.close();
  });
}
