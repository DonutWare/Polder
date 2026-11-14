import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/offline/offline_storage_provider.dart";

import "provider_harness.dart";

Future<void> settleAsync(WidgetTester tester) async {
  for (var round = 0; round < 10; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
}

Future<void> sendQueuedTags(WidgetTester tester, ProviderHarness harness) async {
  await settleAsync(tester);
  final tags = await tester.runAsync(() => harness.container.read(offlineTagsProvider.future));
  var done = false;
  final pushed = tags!.push().whenComplete(() => done = true);
  for (var round = 0; !done && round < 500; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
  expect(done, isTrue, reason: "queued tag changes were not sent");
  await pushed;
  await tester.pump(const Duration(seconds: 2));
  await settleAsync(tester);
}
