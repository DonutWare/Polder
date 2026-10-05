import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/desktop/tray_status_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";
import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/services/sync/sync_activity.dart";

import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  const root = SyncRoot(id: "r", accountId: "a", localPath: "/local", remotePath: "/Docs");

  Future<TrayStatus> status() async {
    await pumpEventQueue();
    return harness.container.read(trayStatusProvider);
  }

  Future<void> signIn() async {
    harness = ProviderHarness(account: testAccount());
    harness.container.listen(trayStatusProvider, (_, _) {});
    await harness.container.read(accountProvider.future);
  }

  tearDown(() => harness.dispose());

  test("without an account the tray shows signed out", () async {
    harness = ProviderHarness();
    harness.container.listen(trayStatusProvider, (_, _) {});
    await harness.container.read(accountProvider.future);

    expect((await status()).phase, TrayPhase.signedOut);
  });

  test("files that are only waiting leave the tray idle", () async {
    await signIn();
    harness.container.read(syncActivityProvider).enqueue(root, ["a.txt"]);

    expect(await status(), const TrayStatus(TrayPhase.idle));
  });

  test("uploads count as syncing and add up their rates", () async {
    await signIn();
    final activity = harness.container.read(syncActivityProvider)
      ..enqueue(root, ["a.txt", "b.txt"])
      ..begin(root, "a.txt", LocalSyncPhase.uploading, total: 1000)
      ..progress(root.id, "a.txt", 0);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    activity.progress(root.id, "a.txt", 500);
    await Future<void>.delayed(SyncActivity.notifyInterval * 2);

    final tray = await status();
    expect(tray.phase, TrayPhase.syncing);
    expect(tray.files, 2);
    expect(tray.uploadRate, greaterThan(0));
  });

  test("pausing wins over running uploads", () async {
    await signIn();
    harness.container.listen(syncPausedProvider, (_, _) {});
    harness.container.read(syncActivityProvider)
      ..enqueue(root, ["a.txt"])
      ..begin(root, "a.txt", LocalSyncPhase.uploading, total: 10);

    await harness.container.read(syncPausedProvider.notifier).pause();

    expect(await status(), const TrayStatus(TrayPhase.paused));
  });

  test("a failed run shows as an error", () async {
    await signIn();
    harness.container.listen(syncRootsProvider, (_, _) {});
    harness.container.listen(syncStatusProvider, (_, _) {});
    await harness.container
        .read(syncRootsProvider.notifier)
        .add(localPath: "/tmp/sync", remotePath: "/", mode: SyncMode.sync);
    harness.syncPlatform.service.nextReport = SyncRunReport.failure("boom");

    await harness.container.read(syncStatusProvider.notifier).syncNow();

    expect((await status()).phase, TrayPhase.error);
  });
}
