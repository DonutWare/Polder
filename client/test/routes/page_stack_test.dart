import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/theme/fading_predictive_back.dart";
import "package:polder/widgets/navigation/intercept_back.dart";
import "package:polder/util/remote_path.dart";

void main() {
  late GoRouter router;

  Future<void> pumpApp(WidgetTester tester, String initialLocation, {bool intercepting = false}) async {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (_, _, child) => child,
          routes: [
            GoRoute(
              path: "${AppRoutes.shared}/:share",
              builder: (_, state) => UpScope(
                child: PageStack(
                  pages: [
                    const StackPage(
                      location: AppRoutes.shared,
                      child: Scaffold(body: Text("share-list")),
                    ),
                    StackPage(
                      location: state.uri.path,
                      key: ValueKey(state.uri.path),
                      child: _FolderStack(
                        path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
                        locationFor: (folder) =>
                            Uri(path: state.uri.path, queryParameters: {AppRoutes.pathParameter: folder}).toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.notes,
              builder: (_, _) => const UpScope(child: Scaffold(body: Text("notes-page"))),
            ),
            GoRoute(
              path: AppRoutes.files,
              builder: (_, state) => UpScope(
                child: _FolderStack(path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (_, state) => MaterialPage<void>(
            key: state.pageKey,
            child: const UpScope(child: Scaffold(body: Text("settings-page"))),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      InterceptBack(
        active: intercepting,
        child: MaterialApp.router(
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {TargetPlatform.android: FadingPredictiveBackPageTransitionsBuilder()},
            ),
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.toString();

  Future<void> sendGesture(String method, [Object? arguments]) =>
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.backGesture.name,
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
        (_) {},
      );

  Future<void> swipeBack(WidgetTester tester) async {
    await sendGesture("startBackGesture", {
      "touchOffset": [4.0, 300.0],
      "progress": 0.0,
      "swipeEdge": 0,
    });
    await tester.pump();
    await sendGesture("updateBackGestureProgress", {
      "touchOffset": [200.0, 300.0],
      "progress": 0.6,
      "swipeEdge": 0,
    });
    await tester.pump();
    expect(find.text(RemotePath.parent(Uri.parse(location()).queryParameters["path"] ?? "/")), findsOneWidget);
    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();
  }

  testWidgets("a deep link builds every parent folder underneath", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a/b"));

    expect(find.text("/a/b"), findsOneWidget);
    expect(find.text("/a", skipOffstage: false), findsOneWidget);
    expect(find.text("/", skipOffstage: false), findsOneWidget);
  });

  testWidgets("the back gesture reveals and pops to the parent folder", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a/b"));

    await swipeBack(tester);
    expect(location(), AppRoutes.filesAt("/a"));
    expect(find.text("/a"), findsOneWidget);

    await swipeBack(tester);
    expect(location(), AppRoutes.filesAt("/"));
  });

  testWidgets("system back climbs folders one at a time", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a/b"));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.filesAt("/a"));
    expect(find.text("/a"), findsOneWidget);
  });

  testWidgets("nested stacks pop their innermost page first", (tester) async {
    await pumpApp(tester, "/shared/7?path=/a");

    await swipeBack(tester);
    expect(location(), "/shared/7?path=%2F");
    expect(find.text("/"), findsOneWidget);

    await sendGesture("startBackGesture", {
      "touchOffset": [4.0, 300.0],
      "progress": 0.0,
      "swipeEdge": 0,
    });
    await tester.pump();
    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.shared);
  });

  Future<void> startSwipe(WidgetTester tester, {double progress = 0.5}) async {
    await sendGesture("startBackGesture", {
      "touchOffset": [4.0, 300.0],
      "progress": 0.0,
      "swipeEdge": 0,
    });
    await tester.pump();
    await sendGesture("updateBackGestureProgress", {
      "touchOffset": [200.0, 300.0],
      "progress": progress,
      "swipeEdge": 0,
    });
    await tester.pump();
  }

  double opacityAround(WidgetTester tester, String text) => tester
      .widgetList<FadeTransition>(find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)))
      .map((fade) => fade.opacity.value)
      .fold(1, (lowest, value) => value < lowest ? value : lowest);

  double layerOpacityAround(WidgetTester tester, String text) => tester
      .widgetList<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)))
      .map((layer) => layer.opacity)
      .fold(1, (lowest, value) => value < lowest ? value : lowest);

  testWidgets("a pushed page fades out further the more it is swiped", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/"));
    unawaited(router.push(AppRoutes.settings));
    await tester.pumpAndSettle();

    await startSwipe(tester, progress: 0.3);
    final early = opacityAround(tester, "settings-page");
    await sendGesture("updateBackGestureProgress", {
      "touchOffset": [300.0, 300.0],
      "progress": 0.7,
      "swipeEdge": 0,
    });
    await tester.pump();
    final late = opacityAround(tester, "settings-page");

    expect(early, lessThan(1));
    expect(late, lessThan(early));
    expect(find.text("/"), findsOneWidget);

    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();
    expect(find.text("settings-page"), findsNothing);
  });

  testWidgets("a tab's first page shrinks and fades on its way back to files", (tester) async {
    await pumpApp(tester, AppRoutes.notes);

    await startSwipe(tester);
    expect(layerOpacityAround(tester, "notes-page"), lessThan(1));

    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.files);
  });

  testWidgets("a cancelled gesture leaves the page as it was", (tester) async {
    await pumpApp(tester, AppRoutes.notes);

    await startSwipe(tester);
    await sendGesture("cancelBackGesture");
    await tester.pumpAndSettle();

    expect(location(), AppRoutes.notes);
    expect(layerOpacityAround(tester, "notes-page"), 1);
  });

  testWidgets("something intercepting back keeps the gesture from popping folders", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a"), intercepting: true);

    await startSwipe(tester);
    expect(find.text("/"), findsNothing);
    await sendGesture("cancelBackGesture");
    await tester.pumpAndSettle();
  });

  testWidgets("a page covering the folders takes the back gesture alone", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a/b"));
    unawaited(router.push(AppRoutes.settings));
    await tester.pumpAndSettle();

    await sendGesture("startBackGesture", {
      "touchOffset": [4.0, 300.0],
      "progress": 0.0,
      "swipeEdge": 0,
    });
    await tester.pump();
    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();

    expect(find.text("settings-page"), findsNothing);
    expect(find.text("/a/b"), findsOneWidget);
    expect(location(), AppRoutes.filesAt("/a/b"));
  });
}

class _FolderStack extends StatelessWidget {
  const _FolderStack({required this.path, this.locationFor = AppRoutes.filesAt});

  final String path;
  final String Function(String folder) locationFor;

  @override
  Widget build(BuildContext context) {
    final folders = [path];
    while (folders.last != RemotePath.root) {
      folders.add(RemotePath.parent(folders.last));
    }
    return PageStack(
      pages: [
        for (final folder in folders.reversed)
          StackPage(
            location: locationFor(folder),
            child: Scaffold(body: Center(child: Text(folder))),
          ),
      ],
    );
  }
}
