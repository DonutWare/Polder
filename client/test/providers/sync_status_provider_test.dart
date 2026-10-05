import "dart:async";

import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/providers/sync/auto_upload_settings_provider.dart";
import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";
import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_pause.dart";

import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  final account = testAccount();

  setUp(() {
    harness = ProviderHarness(account: account);
    harness.container.listen(syncRootsProvider, (_, _) {});
    harness.container.listen(syncStatusProvider, (_, _) {});
  });

  tearDown(() => harness.dispose());

  Future<void> addRoot(SyncMode mode) =>
      harness.container.read(syncRootsProvider.notifier).add(localPath: "/tmp/$mode", remotePath: "/", mode: mode);

  test("sync now aggregates the report and queues conflicts", () async {
    await addRoot(SyncMode.sync);
    harness.syncPlatform.service.nextReport = const SyncRunReport(
      uploaded: 2,
      conflicts: [Conflict(syncRootId: "r", relativePath: "a.txt", kind: ConflictKind.bothModified)],
    );

    await harness.container.read(syncStatusProvider.notifier).syncNow();

    final status = harness.container.read(syncStatusProvider);
    expect(status.phase, SyncPhase.idle);
    expect(status.lastReport.uploaded, 2);
    expect(status.lastRunAt, isNotNull);
    expect(harness.container.read(conflictQueueProvider).conflicts, hasLength(1));
  });

  test("failures put the status in the error phase", () async {
    await addRoot(SyncMode.sync);
    harness.syncPlatform.service.nextReport = SyncRunReport.failure("boom");

    await harness.container.read(syncStatusProvider.notifier).syncNow();

    expect(harness.container.read(syncStatusProvider).phase, SyncPhase.error);
    expect(harness.container.read(syncStatusProvider).errorMessage, "boom");
  });

  test("auto-upload roots only run when enabled and conditions allow", () async {
    await addRoot(SyncMode.autoUpload);
    final service = harness.syncPlatform.service;
    final settings = harness.container.read(autoUploadSettingsProvider.notifier);

    await harness.container.read(syncStatusProvider.notifier).syncNow();
    expect(service.pausedPathsSeen, isEmpty);

    await settings.setEnabled(true);
    harness.conditions.unmetered = false;
    harness.container.invalidate(autoUploadAllowedProvider);
    await harness.container.read(syncStatusProvider.notifier).syncNow();
    expect(service.pausedPathsSeen, isEmpty);

    harness.conditions.unmetered = true;
    harness.container.invalidate(autoUploadAllowedProvider);
    await harness.container.read(syncStatusProvider.notifier).syncNow();
    expect(service.pausedPathsSeen, hasLength(1));
    expect(harness.syncPlatform.scheduled.last.enabled, isTrue);
  });

  test("a trigger during a running sync queues one more run", () async {
    await addRoot(SyncMode.sync);
    final service = harness.syncPlatform.service..gate = Completer<void>();
    final notifier = harness.container.read(syncStatusProvider.notifier);

    final first = notifier.syncNow();
    await Future<void>.delayed(Duration.zero);
    unawaited(notifier.syncNow());
    unawaited(notifier.syncNow());
    service.gate!.complete();
    await first;

    expect(service.pausedPathsSeen, hasLength(2));
    expect(harness.container.read(syncStatusProvider).phase, SyncPhase.idle);
  });

  test("sync survives slowly loading auto-upload settings on first open", () async {
    final slow = ProviderHarness(account: account, preferences: _SlowPreferencesStore());
    addTearDown(slow.dispose);
    slow.container.listen(syncRootsProvider, (_, _) {});
    slow.container.listen(syncStatusProvider, (_, _) {});
    await slow.container
        .read(syncRootsProvider.notifier)
        .add(localPath: "/tmp/sync", remotePath: "/", mode: SyncMode.sync);

    await slow.container.read(syncStatusProvider.notifier).syncNow();

    final status = slow.container.read(syncStatusProvider);
    expect(status.errorMessage, isNull);
    expect(status.phase, SyncPhase.idle);
  });

  test("pausing stops runs until resumed, and is remembered", () async {
    await addRoot(SyncMode.sync);
    harness.container.listen(syncPausedProvider, (_, _) {});
    final runs = harness.syncPlatform.service.pausedPathsSeen;

    await harness.container.read(syncPausedProvider.notifier).pause();
    runs.clear();
    await harness.container.read(syncStatusProvider.notifier).syncNow();

    expect(runs, isEmpty);
    expect(harness.container.read(syncStatusProvider).phase, SyncPhase.paused);
    expect(await SyncPause.read(harness.preferences), isTrue);

    await harness.container.read(syncPausedProvider.notifier).resume();

    expect(runs, hasLength(1));
    expect(harness.container.read(syncStatusProvider).phase, SyncPhase.idle);
    expect(await SyncPause.read(harness.preferences), isFalse);
  });

  test("turning a sync folder off or removing it stops its work", () async {
    await addRoot(SyncMode.sync);
    final root = (await harness.container.read(syncRootsProvider.future)).single;
    final activity = harness.container.read(syncActivityProvider);
    final run = activity.startRun(root.id);
    final upload = activity.begin(root, "a.bin", LocalSyncPhase.uploading);

    await harness.container.read(syncRootsProvider.notifier).setEnabled(root, false);

    expect(run.reason, CancelReason.stopped);
    expect(upload.isCancelled, isTrue);
    expect(activity.items, isEmpty);
  });
}

class _SlowPreferencesStore extends InMemoryPreferencesStore {
  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return super.readJson(key);
  }
}
