import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/browser_selection_provider.dart";
import "package:polder/screens/browser/widgets/directory_view.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";

import "../../support/fake_server.dart";
import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;

  Future<void> pumpBrowser(WidgetTester tester) async {
    final server = FakePolderServer()
      ..putFile("/a.txt", "a".codeUnits)
      ..putFile("/b.txt", "b".codeUnits)
      ..putFile("/c.txt", "c".codeUnits)
      ..putFile("/d.txt", "d".codeUnits);
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    addTearDown(harness.dispose);
    await tester.runAsync(() => harness.container.read(accountProvider.future));
    await tester.pumpWidget(localizedApp(harness.container, const Scaffold(body: DirectoryView(path: "/"))));
    await tester.pumpAndSettle();
  }

  Set<String> selected() => harness.container.read(browserSelectionProvider("/")).names;

  Future<void> click(WidgetTester tester, String name) async {
    await tester.tap(find.text(name), kind: PointerDeviceKind.mouse);
    await tester.pump(kDoubleTapTimeout);
  }

  group("on a desktop", () {
    final macOS = TargetPlatformVariant.only(TargetPlatform.macOS);

    testWidgets("click selects, Cmd-click toggles, Shift-click selects a range", (tester) async {
      await pumpBrowser(tester);

      await click(tester, "a.txt");
      expect(selected(), {"a.txt"});

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await click(tester, "c.txt");
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(selected(), {"a.txt", "c.txt"});

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await click(tester, "d.txt");
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(selected(), {"c.txt", "d.txt"});

      await click(tester, "b.txt");
      expect(selected(), {"b.txt"});
    }, variant: macOS);

    testWidgets("keyboard selects all, moves, clears and asks before deleting the selection", (tester) async {
      await pumpBrowser(tester);
      await click(tester, "a.txt");

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(selected(), {"a.txt", "b.txt", "c.txt", "d.txt"});

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(selected(), isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(selected(), {"a.txt", "b.txt"});

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
      expect(find.text("Delete 2 items?"), findsOneWidget);
    }, variant: macOS);

    testWidgets("right-clicking part of the selection offers actions for all of it", (tester) async {
      await pumpBrowser(tester);
      await click(tester, "a.txt");
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await click(tester, "c.txt");
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      await tester.tap(find.text("b.txt"), buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(selected(), {"a.txt", "b.txt", "c.txt"});
      expect(find.text("Rename"), findsNothing);
      expect(find.text("Move"), findsOneWidget);
    }, variant: macOS);
  });

  group("on a touch device", () {
    testWidgets("tapping the icon selects, then taps toggle; there is no menu button", (tester) async {
      await pumpBrowser(tester);
      expect(find.byTooltip("More options"), findsNothing);

      final icon = find.descendant(of: find.widgetWithText(ListTile, "b.txt"), matching: find.byType(FileThumbnail));
      await tester.tap(icon);
      await tester.pump();
      expect(selected(), {"b.txt"});

      await tester.tap(find.text("d.txt"));
      await tester.pump();
      expect(selected(), {"b.txt", "d.txt"});
    });

    testWidgets("long press opens the menu", (tester) async {
      await pumpBrowser(tester);

      await tester.longPress(find.text("c.txt"));
      await tester.pumpAndSettle();

      expect(find.text("Rename"), findsOneWidget);
      expect(selected(), isEmpty);
    });
  });
}
