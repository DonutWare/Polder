import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_space.dart";
import "package:polder/providers/sharing/public_link_session_provider.dart";
import "package:polder/screens/shared/widgets/space_directory_view.dart";
import "package:polder/screens/viewer/shared_note_screen.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

Map<String, Object?> _entry(String path, String mime) => {
  "id": 7,
  "path": path,
  "name": path.substring(1),
  "isDir": false,
  "size": 4,
  "mtime": "2026-10-01T10:00:00Z",
  "rev": 1,
  "hash": "",
  "mime": mime,
  "meta": <String, Object?>{},
  "previewState": "none",
};

void main() {
  const space = LinkSpace(serverUrl: "https://files.example.com", code: "Ab3dE9xQ2k");
  late ScriptedClient client;
  late ProviderHarness harness;

  setUp(() {
    client = ScriptedClient((request) async {
      final token = request.headers["x-polder-share-token"];
      return switch ((request.method, request.path)) {
        ("GET", "/public/links/Ab3dE9xQ2k") => jsonResponse(200, {
          "needsPassword": false,
          "permissions": {"view": true, "download": true, "upload": false},
        }),
        ("POST", "/public/links/Ab3dE9xQ2k/unlock") => jsonResponse(200, {
          "token": "token-1",
          "expiresAt": DateTime.now().add(const Duration(hours: 2)).toUtc().toIso8601String(),
          "info": {
            "needsPassword": false,
            "permissions": {"view": true, "download": true, "upload": false},
            "name": "Trip",
            "isDir": true,
          },
          "root": {..._entry("/", "inode/directory"), "isDir": true, "name": "Trip"},
        }),
        ("GET", "/public/links/Ab3dE9xQ2k/list") when token == "token-1" => jsonResponse(200, {
          "path": "/",
          "entries": [_entry("/plan.md", "text/markdown"), _entry("/data.bin", "application/octet-stream")],
          "indexing": false,
        }),
        ("GET", "/public/links/Ab3dE9xQ2k/content") when token == "token-1" => textResponse(
          200,
          "# Day one\n\nVisit the harbour.",
          contentType: "text/markdown",
        ),
        ("GET", "/office/capabilities") => jsonResponse(200, {"enabled": false}),
        _ => jsonResponse(404, {
          "error": {"code": "not_found", "message": "nope"},
        }),
      };
    });
    harness = ProviderHarness(httpClient: client);
  });

  tearDown(() => harness.dispose());

  Future<void> showFolder(WidgetTester tester) async {
    harness.container.listen(publicLinkSessionProvider(space), (_, _) {});
    await tester.runAsync(() => harness.container.read(publicLinkSessionProvider(space).future));
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Scaffold(
          body: SpaceDirectoryView(
            location: const SpaceLocation(space: space, path: "/"),
            onOpenFolder: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("a note in a shared folder opens read-only", (tester) async {
    await showFolder(tester);

    await tester.tap(find.text("plan.md"));
    await tester.pumpAndSettle();

    expect(find.byType(SharedNoteScreen), findsOneWidget);
    expect(find.text("Day one"), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
    expect(client.requests.where((request) => request.method != "GET" && !request.path.endsWith("/unlock")), isEmpty);
    await tester.pump(const Duration(minutes: 6));
  });

  testWidgets("a file without a viewer shows its details", (tester) async {
    await showFolder(tester);

    await tester.tap(find.text("data.bin"));
    await tester.pumpAndSettle();

    expect(find.byType(SharedNoteScreen), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.pump(const Duration(minutes: 6));
  });
}
