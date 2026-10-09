import "dart:async";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/widgets/layout/mouse_navigation.dart";

void main() {
  group("NavigationHistory", () {
    test("visiting after going back drops the forward locations", () {
      final history = const NavigationHistory().visit("/a").visit("/b").visit("/c").moveTo(1).visit("/d");
      expect(history.locations, ["/a", "/b", "/d"]);
      expect(history.next, isNull);
      expect(history.previous, "/b");
    });

    test("replacing swaps the current location", () {
      final history = const NavigationHistory().visit("/a").visit("/b").visit("/c", replace: true);
      expect(history.locations, ["/a", "/c"]);
    });

    test("adjacent locations are followed when the browser moves", () {
      final history = const NavigationHistory().visit("/a").visit("/b");
      expect(history.visit("/a", followAdjacent: true).index, 0);
      expect(history.visit("/a").locations, ["/a", "/b", "/a"]);
    });

    test("signing out forgets the history", () {
      final history = const NavigationHistory().visit("/a").visit(AppRoutes.login);
      expect(history.previous, isNull);
      expect(history.current, isNull);
    });

    test("only the most recent locations are kept", () {
      var history = const NavigationHistory();
      for (var number = 0; number < NavigationHistory.maxLocations + 5; number++) {
        history = history.visit("/$number");
      }
      expect(history.locations, hasLength(NavigationHistory.maxLocations));
      expect(history.current, "/${NavigationHistory.maxLocations + 4}");
    });
  });

  group("mouse navigation", () {
    late GoRouter router;

    Future<void> pumpApp(WidgetTester tester) async {
      router = GoRouter(
        initialLocation: "/a",
        routes: [
          for (final name in ["a", "b", "c"])
            GoRoute(
              path: "/$name",
              builder: (_, _) => Scaffold(body: Center(child: Text(name))),
            ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [routerProvider.overrideWithValue(router)],
          child: MaterialApp.router(
            routerConfig: router,
            builder: (_, child) => MouseNavigation(child: child!),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> click(WidgetTester tester, int button) async {
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse, buttons: button);
      await gesture.down(tester.getCenter(find.byType(Scaffold)));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets("side buttons move back and forward through visited screens", (tester) async {
      await pumpApp(tester);
      router.go("/b");
      await tester.pumpAndSettle();
      router.go("/c");
      await tester.pumpAndSettle();

      await click(tester, kBackMouseButton);
      expect(find.text("b"), findsOneWidget);
      await click(tester, kBackMouseButton);
      expect(find.text("a"), findsOneWidget);
      await click(tester, kBackMouseButton);
      expect(find.text("a"), findsOneWidget);

      await click(tester, kForwardMouseButton);
      expect(find.text("b"), findsOneWidget);
      await click(tester, kForwardMouseButton);
      expect(find.text("c"), findsOneWidget);
    });

    testWidgets("back closes pushed screens and dialogs before leaving the screen", (tester) async {
      await pumpApp(tester);
      router.go("/b");
      await tester.pumpAndSettle();
      unawaited(router.push("/c"));
      await tester.pumpAndSettle();
      unawaited(showDialog<void>(context: tester.element(find.text("c")), builder: (_) => const Text("dialog")));
      await tester.pumpAndSettle();

      await click(tester, kBackMouseButton);
      expect(find.text("dialog"), findsNothing);
      expect(find.text("c"), findsOneWidget);
      await click(tester, kBackMouseButton);
      expect(find.text("b"), findsOneWidget);
      await click(tester, kBackMouseButton);
      expect(find.text("a"), findsOneWidget);
    });
  });
}
