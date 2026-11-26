import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/screens/notes/widgets/notes_grid.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

Map<String, Object?> _entry(String path, {bool isDir = false}) => {
  "id": path.hashCode.abs(),
  "path": path,
  "name": path.substring(path.lastIndexOf("/") + 1),
  "isDir": isDir,
  "size": 4,
  "mtime": "2026-10-01T10:00:00Z",
  "rev": 1,
  "hash": "",
  "mime": isDir ? "inode/directory" : "text/markdown",
  "meta": <String, Object?>{},
  "previewState": "none",
};

void main() {
  const longName = "A rather long page name that keeps going";

  Future<http.StreamedResponse> respond(RecordedRequest request) async => switch (request.path) {
    "/auth/me" => jsonResponse(200, userJson()),
    "/notes/list" => jsonResponse(200, {
      "path": "/Notes",
      "items": [
        {"entry": _entry("/Notes/$longName.md")},
        {"entry": _entry("/Notes/$longName", isDir: true), "hasNotes": true},
        {"entry": _entry("/Notes/Short.md")},
      ],
    }),
    _ => http.StreamedResponse(Stream.value(utf8.encode("Some words in the first paragraph.")), 200),
  };

  for (final width in [150.0, 320.0, 900.0]) {
    testWidgets("cards fit without overflowing at $width wide", (tester) async {
      final harness = ProviderHarness(httpClient: ScriptedClient(respond), account: testAccount());
      await tester.pumpWidget(
        localizedApp(
          harness.container,
          Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 800,
                child: NotesGrid(folder: "/Notes", selectedPath: null, onOpen: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(longName), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      harness.dispose();
    });
  }
}
