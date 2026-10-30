import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";

void main() {
  final node = NoteTreeNode(
    page: FileEntry(path: "/Notes/Trip.md", name: "Trip.md", mtime: DateTime.utc(2026)),
  );

  Future<List<Rect>> holdThenMove(WidgetTester tester, Offset movement) async {
    final holds = <Rect>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: NoteDragSource(
              nodes: [node],
              onHold: holds.add,
              child: const SizedBox(width: 200, height: 48, child: Text("Trip")),
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(tester.getCenter(find.text("Trip")));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    if (movement != Offset.zero) {
      await gesture.moveBy(movement);
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    return holds;
  }

  testWidgets("holding a note without moving asks for its menu", (tester) async {
    final holds = await holdThenMove(tester, Offset.zero);

    expect(holds, [tester.getRect(find.byType(NoteDragSource))]);
  });

  testWidgets("holding and dragging a note moves it instead of opening the menu", (tester) async {
    final holds = await holdThenMove(tester, const Offset(0, 120));

    expect(holds, isEmpty);
  });
}
