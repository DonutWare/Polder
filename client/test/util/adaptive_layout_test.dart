import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/util/adaptive_layout/adaptive_layout.dart";

void main() {
  for (final (width, viewSize, layoutMode) in [
    (599.5, ViewSize.phone, LayoutMode.single),
    (600.0, ViewSize.tablet, LayoutMode.single),
    (959.0, ViewSize.tablet, LayoutMode.single),
    (960.0, ViewSize.tablet, LayoutMode.dual),
    (1920.0, ViewSize.desktop, LayoutMode.dual),
    (2600.0, ViewSize.television, LayoutMode.dual),
  ]) {
    testWidgets("a ${width}px window is a ${viewSize.name} in ${layoutMode.name} mode", (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late ViewSize seenSize;
      late LayoutMode seenMode;
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => AdaptiveLayoutBuilder(child: (_) => child!),
          home: Builder(
            builder: (context) {
              seenSize = AdaptiveLayout.viewSizeOf(context);
              seenMode = AdaptiveLayout.layoutModeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seenSize, viewSize);
      expect(seenMode, layoutMode);
    });
  }

  testWidgets("touching the screen switches to touch input, a mouse back to pointer", (tester) async {
    late InputDevice seen;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => AdaptiveLayoutBuilder(child: (_) => child!),
        home: Builder(
          builder: (context) {
            seen = AdaptiveLayout.inputDeviceOf(context);
            return const SizedBox.expand();
          },
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(const Offset(10, 10));
    await mouse.up();
    await tester.pump();
    expect(seen, InputDevice.pointer);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(seen, InputDevice.touch);
  });
}
