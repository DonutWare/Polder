import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/widgets/tags/tag_picker.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

Map<String, Object?> _tag(int id, String name, int count) => {
  "id": id,
  "name": name,
  "color": "#3e63dd",
  "count": count,
};

void main() {
  late ScriptedClient client;
  late ProviderHarness harness;
  late List<Map<String, Object?>> tags;

  setUp(() async {
    tags = [_tag(1, "work", 3), _tag(2, "home", 1), _tag(3, "travel", 0)];
    client = ScriptedClient(
      (request) async => switch ((request.method, request.path)) {
        (_, "/auth/me") => jsonResponse(200, userJson()),
        ("GET", "/tags") => jsonResponse(200, tags),
        ("POST", "/tags") => () {
          final created = _tag(9, (request.data! as Map)["name"] as String, 0);
          tags = [...tags, created];
          return jsonResponse(201, created);
        }(),
        ("POST", "/tags/assign" || "/tags/unassign") => jsonResponse(200, {
          "results": [
            for (final path in (request.data! as Map)["paths"] as List) {"path": path},
          ],
        }),
        _ => jsonResponse(404, {
          "error": {"code": "not_found", "message": "${request.path} is not scripted"},
        }),
      },
    );
    harness = ProviderHarness(httpClient: client, account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  Future<void> showPicker(WidgetTester tester, List<FileEntry> entries) async {
    await tester.pumpWidget(localizedApp(harness.container, Scaffold(body: TagPicker(entries: entries))));
    await tester.pumpAndSettle();
  }

  final photo = FileEntry(
    id: 7,
    path: "/Photos/beach.jpg",
    name: "beach.jpg",
    mtime: DateTime(2026),
    tagIds: const [1],
  );
  final other = FileEntry(id: 8, path: "/Photos/hike.jpg", name: "hike.jpg", mtime: DateTime(2026));

  testWidgets("typing shortens the list", (tester) async {
    await showPicker(tester, [photo]);
    expect(find.text("#work"), findsOneWidget);
    expect(find.text("#home"), findsOneWidget);
    await tester.enterText(find.byType(TextField), "tra");
    await tester.pump();
    expect(find.text("#travel"), findsOneWidget);
    expect(find.text("#work"), findsNothing);
  });

  testWidgets("checks carried tags and toggles them for every item", (tester) async {
    await showPicker(tester, [photo, other]);
    final work = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, "#work"));
    expect(work.value, isNull);

    await tester.tap(find.text("#work"));
    await tester.pumpAndSettle();
    final assign = client.requests.lastWhere((request) => request.path == "/tags/assign");
    expect(assign.data, {
      "paths": ["/Photos/beach.jpg", "/Photos/hike.jpg"],
      "names": ["work"],
    });
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, "#work")).value, isTrue);
  });

  testWidgets("an unknown name can be created and is assigned", (tester) async {
    await showPicker(tester, [other]);
    await tester.enterText(find.byType(TextField), "garden");
    await tester.pump();
    await tester.tap(find.text("Create #garden"));
    await tester.pumpAndSettle();
    expect(client.requests.any((request) => request.method == "POST" && request.path == "/tags"), isTrue);
    final assign = client.requests.lastWhere((request) => request.path == "/tags/assign");
    expect((assign.data! as Map)["names"], ["garden"]);
  });

  testWidgets("a name with a space is rejected", (tester) async {
    await showPicker(tester, [other]);
    await tester.enterText(find.byType(TextField), "two words");
    await tester.pump();
    expect(find.textContaining("without spaces"), findsOneWidget);
    expect(find.textContaining("Create"), findsNothing);
  });
}
