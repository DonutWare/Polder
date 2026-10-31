import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/screens/tags/tags_screen.dart";

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
    tags = [_tag(1, "work", 3), _tag(2, "someday", 0), _tag(3, "later", 0)];
    client = ScriptedClient(
      (request) async => switch ((request.method, request.path)) {
        (_, "/auth/me") => jsonResponse(200, userJson()),
        ("GET", "/tags") => jsonResponse(200, tags),
        ("DELETE", "/tags/unused") => () {
          final before = tags.length;
          tags = [
            for (final tag in tags)
              if (tag["count"] != 0) tag,
          ];
          return jsonResponse(200, {"removed": before - tags.length});
        }(),
        _ => jsonResponse(404, {
          "error": {"code": "not_found", "message": "${request.path} is not scripted"},
        }),
      },
    );
    harness = ProviderHarness(httpClient: client, account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  testWidgets("deleting unused tags asks first and keeps tags in use", (tester) async {
    await tester.pumpWidget(localizedApp(harness.container, const TagsScreen()));
    await tester.pumpAndSettle();
    expect(find.text("#someday"), findsOneWidget);

    await tester.tap(find.byTooltip("Delete unused tags"));
    await tester.pumpAndSettle();
    expect(find.textContaining("2 tags are not on any item"), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, "Delete"));
    await tester.pumpAndSettle();

    expect(client.requests.where((request) => request.path == "/tags/unused"), hasLength(1));
    expect(find.text("#work"), findsOneWidget);
    expect(find.text("#someday"), findsNothing);
    expect(find.text("2 tags deleted"), findsOneWidget);
    expect(find.byTooltip("Delete unused tags"), findsNothing);
  });
}
