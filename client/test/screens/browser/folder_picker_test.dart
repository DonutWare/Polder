import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";

import "../../support/fake_server.dart";
import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";

void main() {
  testWidgets("folders being moved are greyed out, and the folder they are in can't be chosen", (tester) async {
    final server = FakePolderServer()
      ..putFile("/Photos/p.jpg", "p".codeUnits)
      ..putFile("/Music/m.mp3", "m".codeUnits);
    final harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    addTearDown(harness.dispose);
    await tester.runAsync(() => harness.container.read(accountProvider.future));
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        RemoteFolderPickerDialog(
          initialPath: "/",
          confirmLabel: "Move here",
          excluded: const {"/Photos"},
          canChoose: (path) => path != "/",
        ),
      ),
    );
    await tester.pumpAndSettle();

    ListTile tile(String name) => tester.widget<ListTile>(find.widgetWithText(ListTile, name));
    FilledButton confirm() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, "Move here"));

    expect(tile("Photos").enabled, isFalse);
    expect(tile("Music").enabled, isTrue);
    expect(confirm().onPressed, isNull);

    await tester.tap(find.text("Music"));
    await tester.pumpAndSettle();
    expect(confirm().onPressed, isNotNull);
  });
}
