import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/sync/auto_upload_settings_provider.dart";
import "package:nomad/providers/sync/conflict_queue_provider.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/providers/sync/sync_roots_provider.dart";
import "package:nomad/services/sync/sync_service.dart";

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

class SyncStatusNotifier extends Notifier<SyncStatus> {
  bool _rerunRequested = false;

  @override
  SyncStatus build() {
    ref.watch(currentAccountProvider.select((account) => account?.id));
    return const SyncStatus();
  }

  Future<void> syncNow() async {
    if (!ref.read(syncPlatformProvider).supportsSync) return;
    if (state.isSyncing) {
      _rerunRequested = true;
      return;
    }
    _rerunRequested = false;
    state = state.copyWith(phase: SyncPhase.syncing, errorMessage: null);
    final report = await _runAll();
    if (!ref.mounted) return;
    ref.read(conflictQueueProvider.notifier).enqueue(report.conflicts);
    state = SyncStatus(
      phase: report.hasFailures ? SyncPhase.error : SyncPhase.idle,
      lastReport: report,
      lastRunAt: DateTime.now(),
      errorMessage: report.errors.firstOrNull,
    );
    if (_rerunRequested) await syncNow();
  }

  Future<SyncRunReport> _runAll() async {
    try {
      final service = await ref.read(syncServiceProvider.future);
      var report = const SyncRunReport();
      for (final root in await _runnableRoots()) {
        report += await _runRoot(service, root);
      }
      return report;
    } on Exception catch (error) {
      return SyncRunReport.failure("$error");
    }
  }

  Future<List<SyncRoot>> _runnableRoots() async {
    final roots = (await ref.read(syncRootsProvider.future)).where((root) => root.enabled);
    // Listen instead of read so the auto-dispose provider stays alive until its future resolves.
    final subscription = ref.listen(autoUploadAllowedProvider.future, (_, _) {});
    final bool autoUploadAllowed;
    try {
      autoUploadAllowed = await subscription.read();
    } finally {
      subscription.close();
    }
    return roots.where((root) => root.mode == SyncMode.sync || autoUploadAllowed).toList();
  }

  Future<SyncRunReport> _runRoot(SyncService service, SyncRoot root) async {
    try {
      return await service.run(root, pausedPaths: ref.read(conflictQueueProvider).pausedPaths(root.id));
    } on Exception catch (error) {
      return SyncRunReport.failure("${root.localPath}: $error");
    }
  }
}
