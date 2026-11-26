import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder/providers/browser/file_operations_provider.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";

FileOperationItem _item(String path, {bool isDir = false}) => FileOperationItem(path: path, isDir: isDir);

FileEntry _entry(String name, {bool isDir = false}) =>
    FileEntry(path: "/docs/$name", name: name, isDir: isDir, size: 0, mtime: DateTime(2026), rev: 1);

void main() {
  test("a quick action never shows up", () {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      unawaited(
        container
            .read(fileOperationsProvider.notifier)
            .run(kind: FileOperationKind.delete, items: [_item("/a")], perform: (_) async {}),
      );
      async.elapse(const Duration(seconds: 5));
      expect(container.read(fileOperationsProvider), isEmpty);
    });
  });

  test("a slow move shows which item is busy, then lingers as finished and goes away", () {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final gates = [Completer<void>(), Completer<void>()];
      var next = 0;
      unawaited(
        container
            .read(fileOperationsProvider.notifier)
            .run(
              kind: FileOperationKind.move,
              destination: "/archive",
              items: [_item("/docs/a"), _item("/docs/b")],
              perform: (_) => gates[next++].future,
            ),
      );
      async.elapse(FileOperationsNotifier.revealAfter);
      var operation = container.read(fileOperationsProvider).single;
      expect(
        [for (final item in operation.items) item.state],
        [FileOperationItemState.active, FileOperationItemState.waiting],
      );
      expect(operation.progress, 0);
      expect(container.read(entryOperationsProvider("/docs")).keys, {"a", "b"});
      expect([for (final item in container.read(arrivingItemsProvider("/archive"))) item.name], ["a", "b"]);

      gates[0].complete();
      async.flushMicrotasks();
      operation = container.read(fileOperationsProvider).single;
      expect(operation.completed, 1);
      expect(operation.progress, 0.5);

      gates[1].complete();
      async.flushMicrotasks();
      expect(container.read(fileOperationsProvider).single.finished, isTrue);

      async.elapse(FileOperationsNotifier.lingerFor);
      expect(container.read(fileOperationsProvider), isEmpty);
    });
  });

  test("one failing item does not stop the others and the failure is reported at the end", () {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final performed = <String>[];
      Object? failure;
      container
          .read(fileOperationsProvider.notifier)
          .run(
            kind: FileOperationKind.delete,
            items: [_item("/a"), _item("/b")],
            perform: (item) async {
              performed.add(item.path);
              if (item.path == "/a") throw StateError("locked");
            },
          )
          .then<void>((_) {}, onError: (Object error) => failure = error);
      async.flushMicrotasks();
      expect(performed, ["/a", "/b"]);
      expect(failure, isA<StateError>());
    });
  });

  test("busy entries are marked, finished moves leave and arrivals are placed among the folders", () {
    final items = [
      BrowserItem(entry: _entry("Photos", isDir: true)),
      BrowserItem(entry: _entry("notes.md")),
      BrowserItem(entry: _entry("todo.md")),
    ];
    final merged = mergeFileOperations(
      items,
      busy: {
        "notes.md": const EntryOperation(kind: FileOperationKind.move, state: FileOperationItemState.active),
        "todo.md": const EntryOperation(kind: FileOperationKind.move, state: FileOperationItemState.done),
      },
      arriving: [
        const ArrivingItem(
          name: "Archive",
          isDir: true,
          kind: FileOperationKind.move,
          state: FileOperationItemState.waiting,
        ),
        const ArrivingItem(
          name: "Photos",
          isDir: true,
          kind: FileOperationKind.copy,
          state: FileOperationItemState.done,
        ),
      ],
    );
    expect([for (final item in merged) item.name], ["Archive", "Photos", "notes.md"]);
    expect(merged[0].arriving, isNotNull);
    expect(merged[1].arriving, isNull);
    expect(merged[2].operation?.state, FileOperationItemState.active);
  });
}
