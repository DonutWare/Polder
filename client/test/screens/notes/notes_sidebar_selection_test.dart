import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/note_selection_provider.dart";
import "package:polder/screens/notes/widgets/notes_sidebar.dart";
import "package:polder/widgets/shared/drag_chip.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

Map<String, Object?> _entry(String path) => {
  "id": path.hashCode.abs(),
  "path": path,
  "name": path.substring(path.lastIndexOf("/") + 1),
  "isDir": false,
  "size": 4,
  "mtime": "2026-10-01T10:00:00Z",
  "rev": 1,
  "hash": "",
  "mime": "text/markdown",
  "meta": <String, Object?>{},
  "previewState": "none",
};

void main() {
  late ScriptedClient client;
  late ProviderHarness harness;

  setUp(() async {
    client = ScriptedClient(
      (request) async => switch (request.path) {
        "/auth/me" => jsonResponse(200, userJson()),
        "/notes/list" => jsonResponse(200, {
          "path": "/Notes",
          "items": [
            for (final name in ["A", "B", "C", "D"]) {"entry": _entry("/Notes/$name.md")},
          ],
        }),
        "/files/move" => jsonResponse(200, _entry((request.data! as Map)["to"] as String)),
        _ => jsonResponse(404, {
          "error": {"code": "not_found", "message": "${request.path} is not scripted"},
        }),
      },
    );
    harness = ProviderHarness(httpClient: client, account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  Future<void> showTree(WidgetTester tester) async {
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Scaffold(
          body: NotesSidebar(root: "/Notes", selectedPath: null, onOpen: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> clickWith(WidgetTester tester, LogicalKeyboardKey key, String name) async {
    await tester.sendKeyDownEvent(key);
    await tester.tap(find.text(name));
    await tester.sendKeyUpEvent(key);
    await tester.pump();
  }

  Set<String> selected() => harness.container.read(noteSelectionProvider).names;

  testWidgets("command-click picks notes and shift-click selects a range", (tester) async {
    await showTree(tester);

    await clickWith(tester, LogicalKeyboardKey.metaLeft, "A");
    await clickWith(tester, LogicalKeyboardKey.metaLeft, "C");
    expect(selected(), {"/Notes/A.md", "/Notes/C.md"});

    await clickWith(tester, LogicalKeyboardKey.shiftLeft, "D");
    expect(selected(), {"/Notes/C.md", "/Notes/D.md"});

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(selected(), isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets("dragging a selected note moves every selected note", (tester) async {
    await showTree(tester);
    await clickWith(tester, LogicalKeyboardKey.metaLeft, "A");
    await clickWith(tester, LogicalKeyboardKey.metaLeft, "B");

    final drag = await tester.startGesture(tester.getCenter(find.text("A")), kind: PointerDeviceKind.mouse);
    await drag.moveBy(const Offset(0, 20));
    await tester.pump();
    await drag.moveTo(tester.getCenter(find.text("D")));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();

    final moves = [
      for (final request in client.requests.where((request) => request.path == "/files/move"))
        ((request.data! as Map)["from"], (request.data! as Map)["to"]),
    ];
    expect(moves, [("/Notes/A.md", "/Notes/D/A.md"), ("/Notes/B.md", "/Notes/D/B.md")]);
    expect(selected(), isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  Future<TestGesture> dragOver(WidgetTester tester, String from, String to) async {
    final drag = await tester.startGesture(tester.getCenter(find.text(from)), kind: PointerDeviceKind.mouse);
    await drag.moveBy(const Offset(0, 20));
    await tester.pump();
    await drag.moveTo(tester.getCenter(find.text(to)));
    await tester.pump();
    return drag;
  }

  Iterable<RecordedRequest> moves() => client.requests.where((request) => request.path == "/files/move");

  testWidgets("escape stops a drag without moving anything", (tester) async {
    await showTree(tester);
    final drag = await dragOver(tester, "A", "D");
    expect(find.byType(DragChip), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(DragChip), findsNothing);

    await drag.up();
    await tester.pumpAndSettle();
    expect(moves(), isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets("selected notes cannot be dropped onto one of themselves", (tester) async {
    await showTree(tester);
    for (final name in ["A", "B", "C"]) {
      await clickWith(tester, LogicalKeyboardKey.metaLeft, name);
    }

    final drag = await dragOver(tester, "A", "B");
    await drag.up();
    await tester.pumpAndSettle();

    expect(moves(), isEmpty);
    expect(selected(), {"/Notes/A.md", "/Notes/B.md", "/Notes/C.md"});
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
