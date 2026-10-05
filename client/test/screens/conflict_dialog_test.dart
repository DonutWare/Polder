import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/screens/sync/widgets/apply_to_all_checkbox.dart";
import "package:polder/screens/sync/widgets/conflict_dialog.dart";

import "../support/fixtures.dart";
import "../support/localized_app.dart";
import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  final account = testAccount();

  final conflict = Conflict(
    syncRootId: "root",
    relativePath: "docs/report.txt",
    kind: ConflictKind.bothModified,
    local: localFile("docs/report.txt"),
    remote: FileEntry(path: "/docs/report.txt", name: "report.txt", size: 2048, mtime: fixedTime, rev: 12),
  );
  final other = conflict.copyWith(relativePath: "docs/other.txt");

  setUp(() async {
    harness = ProviderHarness(account: account);
    await harness.syncPlatform.store.saveRoot(
      SyncRoot(id: "root", accountId: account.id, localPath: "/tmp/x", remotePath: "/"),
    );
  });

  tearDown(() => harness.dispose());

  Future<void> openDialog(WidgetTester tester, List<Conflict> queued) async {
    await harness.container.read(accountProvider.future);
    harness.container.read(conflictQueueProvider.notifier).enqueue(queued);
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => showConflictDialog(context, queued.first), child: const Text("open")),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets("shows local and server details with the three choices", (tester) async {
    await openDialog(tester, [conflict]);

    expect(find.text("report.txt"), findsOneWidget);
    expect(find.text("This device"), findsOneWidget);
    expect(find.text("Server"), findsOneWidget);
    expect(find.text("2 KB"), findsOneWidget);
    expect(find.text("Revision 12"), findsOneWidget);
    expect(find.text("Changed on this device and on the server."), findsOneWidget);
    expect(find.byKey(ConflictDialog.keepMineKey), findsOneWidget);
    expect(find.byKey(ConflictDialog.keepServerKey), findsOneWidget);
    expect(find.byKey(ConflictDialog.keepBothKey), findsOneWidget);
    expect(find.byKey(ApplyToAllCheckbox.checkboxKey), findsNothing);
  });

  testWidgets("choosing keep both resolves that conflict and closes", (tester) async {
    await openDialog(tester, [conflict, other]);

    await tester.tap(find.byKey(ConflictDialog.keepBothKey));
    await tester.pumpAndSettle();

    expect(find.byType(ConflictDialog), findsNothing);
    expect(harness.syncPlatform.service.resolved, [("docs/report.txt", ConflictResolution.keepBoth)]);
    expect(harness.container.read(conflictQueueProvider).conflicts, [other]);
  });

  testWidgets("apply to all resolves every conflict with the same choice", (tester) async {
    await openDialog(tester, [conflict, other]);

    await tester.tap(find.byKey(ApplyToAllCheckbox.checkboxKey));
    await tester.pump();
    await tester.tap(find.byKey(ConflictDialog.keepServerKey));
    await tester.pumpAndSettle();

    expect(harness.syncPlatform.service.resolved, [
      ("docs/report.txt", ConflictResolution.keepServer),
      ("docs/other.txt", ConflictResolution.keepServer),
    ]);
    expect(harness.container.read(conflictQueueProvider).isEmpty, isTrue);
  });

  testWidgets("a remote delete shows the server side as deleted", (tester) async {
    await openDialog(tester, [conflict.copyWith(kind: ConflictKind.localModifiedRemoteDeleted, remote: null)]);

    expect(find.text("Deleted"), findsOneWidget);
    expect(find.text("Changed on this device but deleted on the server."), findsOneWidget);
  });
}
