import "dart:convert";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
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

  void withNote(void Function(FakeAsync async, ProviderHarness harness, NoteDocumentNotifier note) body) {
    fakeAsync((async) {
      final harness = ProviderHarness(httpClient: SignedInServer(server), account: account, preferences: preferences);
      harness.container.read(accountProvider.future);
      async.flushMicrotasks();
      final subscription = harness.container.listen(noteDocumentProvider(notePath), (_, _) {});
      async.flushMicrotasks();
      body(async, harness, harness.container.read(noteDocumentProvider(notePath).notifier));
      subscription.close();
      async.elapse(const Duration(seconds: 1));
      harness.dispose();
    });
  }

  NoteDocument documentOf(ProviderHarness harness) =>
      harness.container.read(noteDocumentProvider(notePath)).requireValue;

  test("edits reach the server at the checkpoint, not while typing", () {
    withNote((async, harness, note) {
      note.edit("# Plan\n\nFirst idea\n");
      expect(documentOf(harness).state, NoteSaveState.unsaved);
      async.elapse(const Duration(minutes: 4));
      expect(onServer(notePath), "# Plan\n");

      async.elapse(const Duration(minutes: 1));
      expect(onServer(notePath), "# Plan\n\nFirst idea\n");
      expect(documentOf(harness).state, NoteSaveState.saved);
    });
  });

  test("opening a note updates links to files renamed while it was closed", () {
    server.putFile("/Notes/Old.md", utf8.encode("# Old\n"));
    final id = server.idOf("/Notes/Old.md");
    server
      ..putFile(notePath, utf8.encode("See [Old](Old.md?fileId=$id) and [the plan](Old.md?fileId=$id)\n"))
      ..movePath("/Notes/Old.md", "/Notes/Roadmap.md");
    withNote((async, harness, note) {
      async.flushMicrotasks();
      expect(documentOf(harness).state, NoteSaveState.saved);
    });
    expect(onServer(notePath), "See [Roadmap](Roadmap.md?fileId=$id) and [the plan](Roadmap.md?fileId=$id)\n");
  });

  test("unsaved edits are kept when the server only updated links in the note", () {
    server.putFile("/Notes/Old.md", utf8.encode("# Old\n"));
    final id = server.idOf("/Notes/Old.md");
    server.putFile(notePath, utf8.encode("See [Old](Old.md?fileId=$id)\n"));
    withNote((async, harness, note) {
      async.flushMicrotasks();
      note.edit("See [Old](Old.md?fileId=$id)\n\nMy new line\n");
      server
        ..movePath("/Notes/Old.md", "/Notes/Roadmap.md")
        ..putFile(notePath, utf8.encode("See [Roadmap](Roadmap.md?fileId=$id)\n"));
      note.save();
      async.flushMicrotasks();
      expect(documentOf(harness).state, NoteSaveState.saved);
    });
    expect(onServer(notePath), "See [Roadmap](Roadmap.md?fileId=$id)\n\nMy new line\n");
  });

  test("closing the note saves it", () {
    withNote((async, harness, note) => note.edit("# Plan\n\nWritten before closing\n"));
    expect(onServer(notePath), "# Plan\n\nWritten before closing\n");
  });

  test("unsaved text is kept as a draft and offered when the note opens again", () {
    server.failNextPut = true;
    withNote((async, harness, note) {
      note.edit("# Plan\n\nNot on the server yet\n");
      async.elapse(NoteDocumentNotifier.draftDelay);
    });
    expect(onServer(notePath), "# Plan\n");

    withNote((async, harness, note) {
      final draft = documentOf(harness).draft;
      expect(draft?.text, "# Plan\n\nNot on the server yet\n");
      note.recoverDraft();
      expect(documentOf(harness).text, "# Plan\n\nNot on the server yet\n");
      expect(documentOf(harness).draft, isNull);
    });
  });

  test("a change made elsewhere is a conflict the user resolves", () {
    withNote((async, harness, note) {
      note.edit("# Plan\n\nMine\n");
      server.putFile(notePath, utf8.encode("# Plan\n\nTheirs\n"));
      note.save();
      async.flushMicrotasks();
      expect(documentOf(harness).state, NoteSaveState.conflict);

      note.takeTheirs();
      async.flushMicrotasks();
      expect(documentOf(harness).text, "# Plan\n\nTheirs\n");
      expect(documentOf(harness).dirty, isFalse);
    });
  });

  test("a note renamed while open saves to its new name", () {
    withNote((async, harness, note) {
      note.edit("# Plan\n\nAfter the rename\n");
      server.movePath(notePath, "/Notes/Renamed.md");
      note.save();
      async.flushMicrotasks();
      expect(documentOf(harness).state, NoteSaveState.saved);
      expect(documentOf(harness).entry.path, "/Notes/Renamed.md");
    });
    expect(onServer("/Notes/Renamed.md"), "# Plan\n\nAfter the rename\n");
  });
}
