import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/user.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/shell/app_shell.dart";
import "package:polder/widgets/layout/adaptive.dart";

import "../support/localized_app.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late GoRouter router;

  Future<void> pumpShell(WidgetTester tester, UserRole role, {Size size = const Size(400, 800)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final account = testAccount(role: role);
    harness = ProviderHarness(
      httpClient: ScriptedClient(
        (RecordedRequest request) async => switch (request.path) {
          "/auth/me" => jsonResponse(200, userJson(role: role.name)),
          _ => jsonResponse(404, {
            "error": {"code": "not_found", "message": "nope"},
          }),
        },
      ),
      account: account,
    );
    router = GoRouter(
      initialLocation: AppRoutes.files,
      routes: [
        ShellRoute(
          builder: (_, state, child) => AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(path: AppRoutes.files, builder: (_, _) => const Text("files-page")),
            GoRoute(path: AppRoutes.settings, builder: (_, _) => const Text("settings-page")),
          ],
        ),
        GoRoute(path: AppRoutes.admin, builder: (_, _) => const Text("admin-page")),
      ],
    );
    addTearDown(() {
      router.dispose();
      harness.dispose();
    });
    await tester.pumpWidget(localizedRouterApp(harness.container, router));
    await tester.pumpAndSettle();
  }

  Future<void> openMoreOptions(WidgetTester tester) async {
    tester.state<SideSheetDrawerState>(find.byType(SideSheetDrawer)).open();
    await tester.pumpAndSettle();
  }

  testWidgets("administration is not part of the main navigation", (tester) async {
    await pumpShell(tester, UserRole.admin);

    expect(find.byTooltip("Files"), findsOneWidget);
    expect(find.byTooltip("Settings"), findsOneWidget);
    expect(find.byTooltip("Admin"), findsNothing);
    expect(find.byTooltip("Users"), findsNothing);
  });

  testWidgets("administrators reach administration from the menu", (tester) async {
    await pumpShell(tester, UserRole.admin);
    await openMoreOptions(tester);

    await tester.tap(find.text("Administration"));
    await tester.pumpAndSettle();

    expect(find.text("admin-page"), findsOneWidget);
  });

  testWidgets("regular users don't see administration", (tester) async {
    await pumpShell(tester, UserRole.user);
    await openMoreOptions(tester);

    expect(find.text("Account"), findsOneWidget);
    expect(find.text("Administration"), findsNothing);
  });

  testWidgets("large windows get a sidebar with labels", (tester) async {
    await pumpShell(tester, UserRole.user, size: const Size(1400, 900));

    expect(find.text("Files"), findsOneWidget);
    expect(find.text("alice"), findsOneWidget);
    expect(find.text("alice@cloud.test"), findsOneWidget);
  });
}
