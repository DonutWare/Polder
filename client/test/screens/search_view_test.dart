import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user.dart";
import "package:polder/screens/search/search_view.dart";

import "../support/localized_app.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

Map<String, dynamic> _entry(String path, {bool isDir = false}) => {
  "path": path,
  "name": path.split("/").last,
  "isDir": isDir,
  "size": 2048,
  "mtime": "2026-05-01T10:00:00Z",
  "rev": 3,
  "hash": "",
  "mime": isDir ? "inode/directory" : "application/pdf",
  "meta": <String, dynamic>{},
  "previewState": "none",
};

Map<String, dynamic> _results(String query) => {
  "query": query,
  "total": 1,
  "results": [
    {
      "entry": _entry("/Finance/invoice_q3.pdf"),
      "score": 120,
      "nameMatches": [
        {"start": 0, "end": 3},
      ],
    },
  ],
  "filters": [
    if (query.indexOf("type=pdf") case final start when start >= 0)
      {
        "key": "type",
        "op": "is",
        "values": ["pdf"],
        "start": start,
        "end": start + 8,
      },
  ],
  "facets": {"types": <Object>[], "exts": <Object>[]},
  "warnings": <Object>[],
};

void main() {
  late ProviderHarness harness;
  late List<FileEntry> opened;
  late List<String> visited;

  Future<void> pumpSearch(WidgetTester tester, {String initialQuery = ""}) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    opened = [];
    visited = [];
    harness = ProviderHarness(
      httpClient: ScriptedClient(
        (request) async => switch (request.path) {
          "/auth/me" => jsonResponse(200, userJson(role: "admin")),
          "/search" => jsonResponse(200, _results(request.query["q"] ?? "")),
          "/search/suggest" => jsonResponse(200, {"start": 0, "end": 0, "suggestions": <Object>[]}),
          _ => jsonResponse(404, {
            "error": {"code": "not_found", "message": "nope"},
          }),
        },
      ),
      account: testAccount(role: UserRole.admin),
    );
    addTearDown(harness.dispose);
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Scaffold(
          body: SearchView(
            initialQuery: initialQuery,
            onOpenEntry: opened.add,
            onShowInFolder: (_) {},
            onGo: visited.add,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("typing finds files and pages, and enter opens the first", (tester) async {
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), "trash");
    await tester.pumpAndSettle();

    expect(find.text("Go to"), findsOneWidget);
    expect(find.text("1 file"), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(visited, ["/trash"]);
  });

  testWidgets("arrow keys move the selection to a file", (tester) async {
    await pumpSearch(tester, initialQuery: "invoice");

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(opened.single.path, "/Finance/invoice_q3.pdf");
  });
}
