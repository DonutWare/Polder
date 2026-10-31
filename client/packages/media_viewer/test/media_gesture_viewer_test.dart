import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:media_viewer/media_viewer.dart";

void main() {
  const items = ["a", "b", "c"];
  late MediaViewerController controller;
  late List<String> shown;
  late MediaOverlay overlay;

  Widget viewer({bool sideInfo = false}) => MediaGestureViewer<String>(
    items: items,
    itemKey: (item) => item,
    initialItem: "b",
    controller: controller,
    usesPointer: false,
    sideInfo: sideInfo,
    onItemChanged: shown.add,
    pageBuilder: (context, item, page) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: page.onTap,
      child: Center(child: Text("page $item")),
    ),
    overlayBuilder: (context, item, state) {
      overlay = state;
      return const SizedBox.shrink();
    },
    infoBuilder: (context, item, placement) =>
        ColoredBox(color: Colors.white, child: Text("info $item ${placement.name}")),
  );

  Future<void> pumpViewer(WidgetTester tester, {bool sideInfo = false}) async {
    controller = MediaViewerController();
    shown = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(body: viewer(sideInfo: sideInfo)),
              ),
            ),
            child: const Text("open"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets("opens on the initial item and pages with the controller, wrapping only when advancing", (tester) async {
    await pumpViewer(tester);
    expect(find.text("page b"), findsOneWidget);
    expect(shown, ["b"]);
    expect((overlay.index, overlay.count), (1, 3));

    controller.next();
    await tester.pumpAndSettle();
    expect(shown.last, "c");

    controller.next();
    await tester.pumpAndSettle();
    expect(shown.last, "c");

    controller.advance();
    await tester.pumpAndSettle();
    expect(shown.last, "a");
  });

  testWidgets("a tap toggles the overlay", (tester) async {
    await pumpViewer(tester);
    expect(overlay.visible, isTrue);

    await tester.tap(find.text("page b"));
    await tester.pump();
    expect(overlay.visible, isFalse);
  });

  testWidgets("swiping up opens the info sheet and swiping down closes it again", (tester) async {
    await pumpViewer(tester);

    await tester.fling(find.text("page b"), const Offset(0, -300), 1000);
    await tester.pumpAndSettle();
    expect(find.text("info b sheet"), findsOneWidget);
    expect(overlay.visible, isFalse);

    await tester.fling(find.text("page b"), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();
    expect(find.text("info b sheet"), findsNothing);
    expect(find.text("page b"), findsOneWidget);
  });

  testWidgets("swiping down with the sheet closed dismisses the viewer", (tester) async {
    await pumpViewer(tester);

    await tester.fling(find.text("page b"), const Offset(0, 300), 1500);
    await tester.pumpAndSettle();
    expect(find.text("open"), findsOneWidget);
    expect(find.text("page b"), findsNothing);
  });

  testWidgets("on wide layouts the info opens beside the media", (tester) async {
    await pumpViewer(tester, sideInfo: true);

    controller.toggleInfo();
    await tester.pumpAndSettle();
    expect(find.text("info b side"), findsOneWidget);
    expect(overlay.infoOpen, isTrue);

    controller.close();
    await tester.pumpAndSettle();
    expect(find.text("info b side"), findsNothing);
  });

  testWidgets("follows an item that is renamed, and keeps its place when the current item disappears", (tester) async {
    controller = MediaViewerController();
    shown = [];
    var current = ["a", "b", "c"];
    late StateSetter setItems;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setItems = setState;
            return MediaGestureViewer<String>(
              items: current,
              itemKey: (item) => item,
              initialItem: "b",
              controller: controller,
              usesPointer: false,
              sideInfo: false,
              onItemChanged: shown.add,
              pageBuilder: (context, item, page) => Center(child: Text("page $item")),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.show("b2");
    setItems(() => current = ["a", "b2", "c"]);
    await tester.pumpAndSettle();
    expect(find.text("page b2"), findsOneWidget);
    expect(shown.last, "b2");

    setItems(() => current = ["a", "c"]);
    await tester.pumpAndSettle();
    expect(find.text("page c"), findsOneWidget);
    expect(shown.last, "c");
  });
}
