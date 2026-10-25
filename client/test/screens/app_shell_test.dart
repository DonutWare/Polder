import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/user.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/screens/shell/app_shell.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";

import "../support/localized_app.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late GoRouter router;

  Future<void> pumpShell(
    WidgetTester tester,
    UserRole role, {
    Size size = const Size(400, 800),
    String initialLocation = "/files?path=/",
  }) async {
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
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (_, _, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.files,
              redirect: (_, state) =>
                  state.uri.queryParameters.containsKey(AppRoutes.pathParameter) ? null : AppRoutes.filesAt("/"),
              builder: (_, state) => UpScope(
                child: PageStack(
                  pages: [
                    for (final folder in RemotePath.ancestry(state.uri.queryParameters[AppRoutes.pathParameter]!))
                      StackPage(location: AppRoutes.filesAt(folder), child: Text("files:$folder")),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const UpScope(child: Text("settings-page")),
              routes: [
                GoRoute(
                  path: "about",
                  builder: (_, _) => const UpScope(child: Text("about-page")),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.admin,
              builder: (_, _) => const UpScope(child: Text("admin-page")),
            ),
          ],
        ),
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

  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets("only the main destinations live in the bottom bar", (tester) async {
    await pumpShell(tester, UserRole.admin);

    expect(find.byTooltip("Files"), findsOneWidget);
    expect(find.byTooltip("Shared"), findsOneWidget);
    expect(find.byTooltip("Notes"), findsOneWidget);
    for (final hidden in ["Activity", "Auto upload", "Groups", "Trash", "Settings", "Admin"]) {
      expect(find.byTooltip(hidden), findsNothing, reason: hidden);
    }
  });

  testWidgets("the menu lists the pages that open on top of the shell", (tester) async {
    await pumpShell(tester, UserRole.user);
    await openMoreOptions(tester);

    for (final label in ["Activity", "Groups", "Trash", "Settings"]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets("pages from the menu cover the shell and back returns to the folder", (tester) async {
    await pumpShell(tester, UserRole.user, initialLocation: "/files?path=/Photos");
    await openMoreOptions(tester);

    await tester.tap(find.text("Settings"));
    await tester.pumpAndSettle();

    expect(find.text("settings-page"), findsOneWidget);
    expect(find.byTooltip("Files"), findsNothing);

    await pressBack(tester);

    expect(find.text("files:/Photos"), findsOneWidget);
    expect(find.byTooltip("Files"), findsOneWidget);
  });

  for (final (width, keepsNavigation) in [(400.0, false), (700.0, false), (1200.0, true)]) {
    testWidgets("settings at ${width.round()}px ${keepsNavigation ? "keeps" : "hides"} the navigation", (tester) async {
      await pumpShell(tester, UserRole.user, size: Size(width, 900), initialLocation: "/files?path=/Photos");
      unawaited(router.push(AppRoutes.settings));
      await tester.pumpAndSettle();

      expect(find.text("settings-page"), findsOneWidget);
      final navigation = find.byWidgetPredicate(
        (widget) =>
            (widget is Tooltip && widget.message == "Files") || (widget is SidebarItem && widget.label == "Files"),
      );
      expect(navigation, keepsNavigation ? findsOneWidget : findsNothing);
      if (keepsNavigation) {
        final launcher = tester.widget<SidebarItem>(find.widgetWithText(SidebarItem, "Settings"));
        expect(launcher.selected, isTrue);
      }

      await pressBack(tester);
      expect(find.text("files:/Photos"), findsOneWidget);
    });
  }

  testWidgets("rotating deep in a folder keeps back inside the app", (tester) async {
    final handlesBack = <bool>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == "SystemNavigator.setFrameworkHandlesBack") handlesBack.add(call.arguments as bool);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpShell(tester, UserRole.user, initialLocation: AppRoutes.filesAt("/a/b/c"));

    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(handlesBack.last, isTrue);

    await pressBack(tester);
    expect(find.text("files:/a/b"), findsOneWidget);
  });

  testWidgets("at the files root back is left to the system", (tester) async {
    final handlesBack = <bool>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == "SystemNavigator.setFrameworkHandlesBack") handlesBack.add(call.arguments as bool);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpShell(tester, UserRole.user);

    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(handlesBack.last, isFalse);
  });

  testWidgets("back climbs from a deep link to the files root, then leaves the app", (tester) async {
    final exits = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == "SystemNavigator.pop") exits.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpShell(tester, UserRole.user, initialLocation: AppRoutes.about);

    await pressBack(tester);
    expect(find.text("settings-page"), findsOneWidget);

    await pressBack(tester);
    expect(find.text("files:/"), findsOneWidget);
    expect(exits, isEmpty);

    await pressBack(tester);
    expect(exits, hasLength(1));
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
