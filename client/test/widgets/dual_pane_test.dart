import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/routes/up_scope.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/layout/dual_pane.dart";

import "../support/localized_app.dart";

void main() {
  late GoRouter router;

  Future<void> pumpPane(WidgetTester tester, String location, {required double width}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(path: "/files", builder: (_, _) => const Text("files-page")),
        GoRoute(
          path: "/settings",
          builder: (_, _) => const UpScope(child: _Settings()),
        ),
        GoRoute(
          path: "/settings/:page",
          builder: (_, state) => UpScope(child: _Settings(page: state.pathParameters["page"])),
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(localizedRouterApp(container, router));
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets("narrow windows show the selected page on its own, and back returns to the list", (tester) async {
    await pumpPane(tester, "/settings/about", width: 700);

    expect(find.text("about-page"), findsOneWidget);
    expect(find.text("general"), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(location(), "/settings");
    expect(find.text("general"), findsOneWidget);
    expect(find.text("about-page"), findsNothing);
  });

  testWidgets("wide windows show the list beside the first page when nothing is picked", (tester) async {
    await pumpPane(tester, "/settings", width: 1200);

    expect(find.text("general [selected]"), findsOneWidget);
    expect(find.text("general-page"), findsOneWidget);
  });

  testWidgets("picking from the list swaps the page beside it", (tester) async {
    await pumpPane(tester, "/settings", width: 1200);

    await tester.tap(find.text("about"));
    await tester.pumpAndSettle();

    expect(location(), "/settings/about");
    expect(find.text("about [selected]"), findsOneWidget);
    expect(find.text("about-page"), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets("shrinking a wide window keeps showing what the address points at", (tester) async {
    await pumpPane(tester, "/settings", width: 1200);

    tester.view.physicalSize = const Size(700, 900);
    await tester.pumpAndSettle();

    expect(find.text("general"), findsOneWidget);
    expect(find.text("general-page"), findsNothing);
  });
}

class _Settings extends StatelessWidget {
  const _Settings({this.page});

  final String? page;

  @override
  Widget build(BuildContext context) {
    final highlighted = DualPane.highlights(context) ? page ?? "general" : null;
    return DualPane(
      title: const Text("Settings"),
      listLocation: "/settings",
      list: Column(
        children: [
          for (final option in ["general", "about"])
            TextButton(
              onPressed: () => goWithin(context, "/settings/$option"),
              child: Text(option == highlighted ? "$option [selected]" : option),
            ),
        ],
      ),
      placeholder: const Text("nothing"),
      defaultDetail: const _Page(name: "general"),
      detail: page == null ? null : _Page(key: ValueKey(page), name: page!),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) => AppPage(title: Text(name), body: Text("$name-page"));
}
