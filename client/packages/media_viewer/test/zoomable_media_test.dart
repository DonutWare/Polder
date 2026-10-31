import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:media_viewer/media_viewer.dart";

void main() {
  late List<bool> zoomChanges;
  late int taps;

  Future<void> pumpMedia(WidgetTester tester) async {
    zoomChanges = [];
    taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ZoomableMedia(
          active: true,
          contentSize: const Size(400, 300),
          onTap: () => taps++,
          onZoomChanged: zoomChanges.add,
          child: const ColoredBox(color: Colors.blue),
        ),
      ),
    );
  }

  Future<void> tapAt(WidgetTester tester, Offset position) async {
    final gesture = await tester.startGesture(position);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets("a single tap waits out the double tap and then reports a tap", (tester) async {
    await pumpMedia(tester);
    final center = tester.getCenter(find.byType(ZoomableMedia));

    await tapAt(tester, center);
    expect(taps, 0);
    await tester.pump(kDoubleTapTimeout);
    expect(taps, 1);
    expect(zoomChanges, isEmpty);
  });

  testWidgets("a double tap zooms in and a second double tap zooms back out", (tester) async {
    await pumpMedia(tester);
    final center = tester.getCenter(find.byType(ZoomableMedia));

    await tapAt(tester, center);
    await tapAt(tester, center);
    await tester.pumpAndSettle();
    expect(zoomChanges, [true]);

    await tapAt(tester, center);
    await tapAt(tester, center);
    await tester.pumpAndSettle();
    expect(zoomChanges, [true, false]);
    expect(taps, 0);
  });

  testWidgets("double tap and drag down zooms in, dragging back up zooms out", (tester) async {
    await pumpMedia(tester);
    final center = tester.getCenter(find.byType(ZoomableMedia));

    await tapAt(tester, center);
    final drag = await tester.startGesture(center);
    await drag.moveBy(const Offset(0, 40));
    await drag.moveBy(const Offset(0, 120));
    await tester.pump();
    expect(zoomChanges, [true]);

    await drag.moveBy(const Offset(0, -200));
    await tester.pump();
    expect(zoomChanges, [true, false]);
    await drag.up();
    await tester.pump(kDoubleTapTimeout);
    expect(taps, 0);
  });
}
