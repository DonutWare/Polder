import "dart:convert";

import "package:fake_async/fake_async.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/providers/offline/offline_sync_provider.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

const notePath = "/Notes/plan.md";

void main() {
  late FakePolderServer server;
  late InMemoryPreferencesStore preferences;
  final account = testAccount();

  setUp(() {
    server = FakePolderServer()..putFile(notePath, utf8.encode("# Plan\n"));
    preferences = InMemoryPreferencesStore();
  });

  String onServer(String path) => utf8.decode(server.nodes[path]!.bytes);

  const settle = Duration(seconds: 2);

  void withHarness(void Function(FakeAsync async, ProviderHarness harness) body) {
    fakeAsync((async) {
      final harness = ProviderHarness(httpClient: SignedInServer(server), account: account, preferences: preferences);
      harness.container.read(accountProvider.future);
      final sync = harness.container.listen(offlineSyncProvider, (_, _) {});
      async.elapse(const Duration(milliseconds: 10));
      body(async, harness);
      async.elapse(settle);
      sync.close();
      harness.dispose();
      async.elapse(settle);
    });
  }

  ProviderSubscription<AsyncValue<NoteDocument>> open(FakeAsync async, ProviderHarness harness) {
    final subscription = harness.container.listen(noteDocumentProvider(notePath), (_, _) {});
    async.elapse(const Duration(milliseconds: 10));
    return subscription;
  }

  NoteDocumentNotifier noteOf(ProviderHarness harness) =>
      harness.container.read(noteDocumentProvider(notePath).notifier);

  NoteDocument documentOf(ProviderHarness harness) =>
      harness.container.read(noteDocumentProvider(notePath)).requireValue;

  test("edits are saved on the device right after typing and then reach the server", () {
    withHarness((async, harness) {
      final note = open(async, harness);
      noteOf(harness).edit("# Plan\n\nFirst idea\n");
      expect(documentOf(harness).state, NoteSaveState.unsaved);

      async.elapse(NoteDocumentNotifier.saveDelay);
      expect(documentOf(harness).dirty, isFalse);

      async.elapse(settle);
      expect(onServer(notePath), "# Plan\n\nFirst idea\n");
      expect(documentOf(harness).state, NoteSaveState.saved);
      note.close();
    });
  });

  test("opening a note updates links to files renamed while it was closed", () {
    server.putFile("/Notes/Old.md", utf8.encode("# Old\n"));
    final id = server.idOf("/Notes/Old.md");
    server
      ..putFile(notePath, utf8.encode("See [Old](Old.md?fileId=$id) and [the plan](Old.md?fileId=$id)\n"))
      ..movePath("/Notes/Old.md", "/Notes/Roadmap.md");
    withHarness((async, harness) {
      final note = open(async, harness);
      async.elapse(settle);
      expect(documentOf(harness).state, NoteSaveState.saved);
      note.close();
    });
    expect(onServer(notePath), "See [Roadmap](Roadmap.md?fileId=$id) and [the plan](Roadmap.md?fileId=$id)\n");
  });

  test("closing the note keeps what was typed and sends it to the server", () {
    withHarness((async, harness) {
      open(async, harness);
      noteOf(harness).edit("# Plan\n\nWritten before closing\n");
      harness.container.invalidate(noteDocumentProvider(notePath));
    });
    expect(onServer(notePath), "# Plan\n\nWritten before closing\n");
  });

  test("edits made while the server is unreachable stay on the device and are reopened from it", () {
    withHarness((async, harness) {
      var note = open(async, harness);
      server.unreachable = true;
      noteOf(harness).edit("# Plan\n\nWritten offline\n");
      async.elapse(settle);

      expect(documentOf(harness).state, NoteSaveState.failed);
      expect((documentOf(harness).saveError! as OutboxError).kind, OutboxErrorKind.unreachable);
      note.close();
      async.elapse(settle);

      note = open(async, harness);
      expect(documentOf(harness).text, "# Plan\n\nWritten offline\n");
      expect(onServer(notePath), "# Plan\n");

      server.unreachable = false;
      noteOf(harness).retrySync();
      async.elapse(settle);
      expect(onServer(notePath), "# Plan\n\nWritten offline\n");
      expect(documentOf(harness).state, NoteSaveState.saved);
      note.close();
    });
  });

  test("a server that cannot store the note keeps it on the device and says why", () {
    withHarness((async, harness) {
      final note = open(async, harness);
      server.failWrites = (status: 507, code: "storage_full");
      noteOf(harness).edit("# Plan\n\nDisk is full\n");
      async.elapse(settle);

      expect(documentOf(harness).state, NoteSaveState.failed);
      expect((documentOf(harness).saveError! as OutboxError).kind, OutboxErrorKind.storageFull);
      expect(documentOf(harness).text, "# Plan\n\nDisk is full\n");
      note.close();
    });
  });

  test("a draft kept by an earlier version is still offered when the note opens", () {
    preferences.writeJson("noteDraft:${server.idOf(notePath)}", {
      "text": "# Plan\n\nNot on the server yet\n",
      "baseHash": "",
      "updatedAt": DateTime.utc(2026).toIso8601String(),
    });
    withHarness((async, harness) {
      final note = open(async, harness);
      expect(documentOf(harness).draft?.text, "# Plan\n\nNot on the server yet\n");
      noteOf(harness).recoverDraft();
      expect(documentOf(harness).text, "# Plan\n\nNot on the server yet\n");
      expect(documentOf(harness).draft, isNull);
      note.close();
    });
  });

  test("a change made elsewhere is a conflict the user resolves", () {
    withHarness((async, harness) {
      final note = open(async, harness);
      server.putFile(notePath, utf8.encode("# Plan\n\nTheirs\n"));
      noteOf(harness).edit("# Plan\n\nMine\n");
      async.elapse(settle);
      expect(documentOf(harness).state, NoteSaveState.conflict);

      noteOf(harness).takeTheirs();
      async.elapse(settle);
      expect(documentOf(harness).text, "# Plan\n\nTheirs\n");
      expect(documentOf(harness).dirty, isFalse);
      expect(onServer(notePath), "# Plan\n\nTheirs\n");
      note.close();
    });
  });

  test("an edit to a note renamed elsewhere reaches it under its new name", () {
    withHarness((async, harness) {
      final note = open(async, harness);
      server.movePath(notePath, "/Notes/Renamed.md");
      noteOf(harness).edit("# Plan\n\nAfter the rename\n");
      async.elapse(settle);
      note.close();
    });
    expect(onServer("/Notes/Renamed.md"), "# Plan\n\nAfter the rename\n");
  });
}
