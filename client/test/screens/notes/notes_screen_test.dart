import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/screens/notes/notes_screen.dart";
import "package:polder/screens/notes/widgets/notes_setup_dialog.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

void main() {
  testWidgets("a user without a notes folder is asked to set one up", (tester) async {
    final harness = ProviderHarness(
      httpClient: ScriptedClient(
        (RecordedRequest request) async => switch (request.path) {
          "/auth/me" => jsonResponse(200, userJson()),
          "/notes/settings" => jsonResponse(200, <String, dynamic>{}),
          _ => jsonResponse(404, {
            "error": {"code": "not_found", "message": "nope"},
          }),
        },
      ),
      account: testAccount(),
    );
    addTearDown(harness.dispose);
    await tester.pumpWidget(localizedApp(harness.container, const NotesScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(NotesSetupDialog), findsOneWidget);
  });
}
