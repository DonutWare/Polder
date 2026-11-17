import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/navigation/navigation_history_scope.dart";

void main() {
  late GoRouter router;

  Future<void> pumpApp(WidgetTester tester, String initialLocation) async {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (_, _, child) => child,
          routes: [
            GoRoute(
              path: AppRoutes.files,
              redirect: (_, state) => state.uri.queryParameters.containsKey(AppRoutes.pathParameter)
                  ? null
                  : AppRoutes.filesAt(RemotePath.root),
              builder: (_, state) => UpScope(
                child: _FolderStack(path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root),
              ),
            ),
            GoRoute(
              path: AppRoutes.notes,
              builder: (_, state) => UpScope(child: _Notes(note: state.uri.queryParameters[AppRoutes.pathParameter])),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (_, child) => NavigationHistoryScope(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.toString();

  Future<void> go(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpAndSettle();
  }

  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<bool> backLeavesApp(WidgetTester tester) async {
    var left = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == "SystemNavigator.pop") left = true;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await systemBack(tester);
    return left;
  }

  Future<void> sendGesture(String method, [Object? arguments]) =>
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.backGesture.name,
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
        (_) {},
      );

  testWidgets("back from a note opened in files returns to that folder", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a"));
    await go(tester, AppRoutes.noteAt("/a/note.md"));

    await systemBack(tester);

    expect(location(), AppRoutes.filesAt("/a"));
    expect(find.text("/a"), findsOneWidget);
  });

  testWidgets("the top bar arrow of a note opened in files returns to that folder", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a"));
    await go(tester, AppRoutes.noteAt("/a/note.md"));

    await tester.tap(find.byKey(const ValueKey("note-up")));
    await tester.pumpAndSettle();

    expect(location(), AppRoutes.filesAt("/a"));
    expect(find.text("/a"), findsOneWidget);
  });

  testWidgets("a replacing navigation does not leave a step to go back to", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a"));
    await go(tester, AppRoutes.notes);

    goWithin(tester.element(find.text("notes-list")), AppRoutes.noteAt("/note.md"), replacing: true);
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.noteAt("/note.md"));

    await systemBack(tester);
    expect(location(), AppRoutes.filesAt("/a"));
  });

  testWidgets("the back gesture on a note opened in files returns to that folder", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a"));
    await go(tester, AppRoutes.noteAt("/a/note.md"));

    await sendGesture("startBackGesture", {
      "touchOffset": [4.0, 300.0],
      "progress": 0.0,
      "swipeEdge": 0,
    });
    await tester.pump();
    await sendGesture("commitBackGesture");
    await tester.pumpAndSettle();

    expect(location(), AppRoutes.filesAt("/a"));
  });

  testWidgets("back from a note opened in the notes list returns to the list", (tester) async {
    await pumpApp(tester, AppRoutes.notes);
    await go(tester, AppRoutes.noteAt("/note.md"));

    await systemBack(tester);

    expect(location(), AppRoutes.notes);
    expect(find.text("notes-list"), findsOneWidget);
  });

  testWidgets("going back repeatedly retraces every screen without looping", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/"));
    await go(tester, AppRoutes.filesAt("/a"));
    await go(tester, AppRoutes.noteAt("/a/note.md"));

    await systemBack(tester);
    expect(location(), AppRoutes.filesAt("/a"));

    await systemBack(tester);
    expect(location(), AppRoutes.filesAt("/"));
  });

  testWidgets("a screen opened directly still goes up when there is nothing to return to", (tester) async {
    await pumpApp(tester, AppRoutes.noteAt("/note.md"));

    await systemBack(tester);

    expect(location(), AppRoutes.notes);
  });

  testWidgets("a tab opened directly goes up to files and then leaves the app", (tester) async {
    await pumpApp(tester, AppRoutes.notes);

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.filesAt(RemotePath.root));

    expect(await backLeavesApp(tester), isTrue);
  });

  testWidgets("a note opened directly climbs to files and then leaves the app", (tester) async {
    await pumpApp(tester, AppRoutes.noteAt("/note.md"));

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.notes);

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.filesAt(RemotePath.root));

    expect(await backLeavesApp(tester), isTrue);
  });

  testWidgets("a nested folder opened directly climbs to the root and then leaves the app", (tester) async {
    await pumpApp(tester, AppRoutes.filesAt("/a/b"));

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.filesAt("/a"));

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.filesAt(RemotePath.root));

    expect(await backLeavesApp(tester), isTrue);
  });

  testWidgets("going up after retracing a visit leaves the app instead of bouncing back", (tester) async {
    await pumpApp(tester, AppRoutes.notes);
    await go(tester, AppRoutes.filesAt("/a"));

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.notes);

    expect(await backLeavesApp(tester), isFalse);
    expect(location(), AppRoutes.filesAt(RemotePath.root));

    expect(await backLeavesApp(tester), isTrue);
  });
}

class _Notes extends StatelessWidget {
  const _Notes({this.note});

  final String? note;

  @override
  Widget build(BuildContext context) => PageStack(
    pages: [
      const StackPage(
        location: AppRoutes.notes,
        key: ValueKey("list"),
        child: Scaffold(body: Text("notes-list")),
      ),
      if (note case final note?)
        StackPage(
          location: AppRoutes.noteAt(note),
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  key: const ValueKey("note-up"),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => UpScope.navigateUp(context),
                ),
              ),
              body: Text(note),
            ),
          ),
        ),
    ],
  );
}

class _FolderStack extends StatelessWidget {
  const _FolderStack({required this.path});

  final String path;

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
            location: AppRoutes.filesAt(folder),
            child: Scaffold(body: Center(child: Text(folder))),
          ),
      ],
    );
  }
}
