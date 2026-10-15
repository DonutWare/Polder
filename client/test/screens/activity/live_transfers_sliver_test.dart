import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/activity/now_groups_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/screens/activity/widgets/live_transfers_card.dart";
import "package:polder/services/sync/sync_activity.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";

void main() {
  testWidgets("an open folder of many files only builds the rows on screen", (tester) async {
    final harness = ProviderHarness(account: testAccount());
    addTearDown(harness.dispose);
    await harness.container.read(accountProvider.future);
    const root = SyncRoot(id: "r", accountId: "a", localPath: "/local", remotePath: "/Docs");
    harness.container.read(syncActivityProvider).enqueue(root, [
      for (var i = 0; i < 1000; i++) "Trip/photo$i.jpg",
    ], downloads: true);
    harness.container.read(openNowGroupsProvider.notifier).toggle("local:r:Trip");

    await tester.pumpWidget(
      localizedApp(harness.container, const Scaffold(body: CustomScrollView(slivers: [LiveTransfersSliver()]))),
    );
    await tester.pump(SyncActivity.notifyInterval * 2);

    expect(find.byType(NowGroupTile), findsOneWidget);
    expect(find.byType(LocalSyncTile).evaluate().length, inInclusiveRange(1, 40));

    await tester.scrollUntilVisible(find.text("photo999.jpg"), 5000, scrollable: find.byType(Scrollable).first);
    expect(find.byType(LocalSyncTile).evaluate().length, inInclusiveRange(1, 40));
  });
}
