import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";
import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/services/sync/sync_scheduler.dart";

final syncSchedulerProvider = Provider<SyncScheduler?>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  if (!platform.supportsSync) return null;
  final roots = (ref.watch(syncRootsProvider).value ?? []).where((root) => root.enabled).toList();
  if (roots.isEmpty) return null;
  final activity = ref.watch(syncActivityProvider);
  final scheduler = SyncScheduler(onTrigger: () => ref.read(syncStatusProvider.notifier).syncNow());
  scheduler.start([
    for (final root in roots.where((root) => root.mode == SyncMode.sync))
      platform.watchFolder(root.localPath).asyncMap((path) => activity.observe(root, path)),
  ]);
  ref.onDispose(scheduler.stop);
  return scheduler;
});
