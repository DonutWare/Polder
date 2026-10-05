import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/trash.dart";
import "package:polder/screens/trash/widgets/restore_conflict_dialog.dart";

import "../support/fixtures.dart";
import "../support/localized_app.dart";
import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  final item = TrashItem(id: 1, name: "report.txt", originalPath: "/docs/report.txt", deletedAt: fixedTime);

  setUp(() => harness = ProviderHarness(account: testAccount()));
  tearDown(() => harness.dispose());

  Future<RestoreMode?> choose(WidgetTester tester, Finder button) async {
    RestoreMode? chosen;
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => chosen = await showRestoreConflictDialog(context, item),
              child: const Text("open"),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    expect(find.text("\"report.txt\" already exists"), findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    return chosen;
  }

  testWidgets("overwrite", (tester) async {
    expect(await choose(tester, find.byKey(RestoreConflictDialog.overwriteKey)), RestoreMode.overwrite);
  });

  testWidgets("keep both", (tester) async {
    expect(await choose(tester, find.byKey(RestoreConflictDialog.keepBothKey)), RestoreMode.keepBoth);
  });

  testWidgets("cancel restores nothing", (tester) async {
    expect(await choose(tester, find.text("Cancel")), isNull);
  });
}
