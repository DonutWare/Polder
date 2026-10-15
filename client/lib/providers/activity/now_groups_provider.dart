import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/activity.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/util/remote_path.dart";

class NowGroup {
  const NowGroup({
    required this.key,
    required this.folder,
    this.local = const [],
    this.transfers = const [],
    this.completed = 0,
    this.rate = 0,
  });

  final String key;
  final String folder;
  final List<PendingUpload> local;
  final List<LiveTransfer> transfers;
  final int completed;
  final int rate;

  int get active => local.length + transfers.length;

  int get totalFiles => active + completed;

  bool get isBatch => totalFiles >= 2;

  int get uploading =>
      local.where((upload) => upload.phase == LocalSyncPhase.uploading).length +
      transfers.where((transfer) => transfer.isUpload).length;

  int get downloading =>
      local.where((upload) => upload.phase == LocalSyncPhase.downloading).length +
      transfers.where((transfer) => !transfer.isUpload).length;

  int get preparing => local.where((upload) => upload.phase == LocalSyncPhase.preparing).length;

  int get waiting => local.where((upload) => upload.phase == LocalSyncPhase.waiting).length;

  double? get progress => totalFiles == 0 ? null : completed / totalFiles;
}

final openNowGroupsProvider = NotifierProvider<OpenNowGroupsNotifier, Set<String>>(OpenNowGroupsNotifier.new);

class OpenNowGroupsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String key) => state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
}

final nowGroupsProvider = Provider<List<NowGroup>>((ref) {
  final scope = ref.watch(activityScopeProvider);
  final selfId = ref.watch(selfUserIdProvider) ?? 0;
  final paused = ref.watch(syncPausedProvider).value ?? false;
  final items = scope.includes(selfId, selfId: selfId)
      ? ref.watch(localSyncItemsProvider).values.toList()
      : const <LocalSyncItem>[];
  final activity = ref.read(syncActivityProvider);
  final completed = activity.completed;

  final localGroups = <String, List<LocalSyncItem>>{};
  for (final item in items) {
    localGroups.putIfAbsent(item.group, () => []).add(item);
  }
  final localPaths = {for (final item in items) item.remotePath};
  bool coveredLocally(LiveTransfer transfer) =>
      localPaths.contains(transfer.path) || localPaths.any((path) => RemotePath.isWithin(path, transfer.path));
  final transferGroups = <String, List<LiveTransfer>>{};
  for (final transfer in ref.watch(scopedTransfersProvider)) {
    if (transfer.userId == selfId && coveredLocally(transfer)) continue;
    transferGroups.putIfAbsent(LiveTransfersNotifier.folderKey(transfer), () => []).add(transfer);
  }
  final live = ref.read(liveTransfersProvider.notifier);
  final finished = live.finishedByFolder;

  return [
    for (final MapEntry(key: group, value: members) in localGroups.entries)
      NowGroup(
        key: "local:$group",
        folder: members.first.groupRemotePath,
        local: [
          for (final item in members..sort((a, b) => a.relativePath.compareTo(b.relativePath)))
            PendingUpload.local(item, paused: paused),
        ],
        completed: completed[group] ?? 0,
        rate: activity.groupRate(group),
      ),
    for (final MapEntry(key: folder, value: transfers) in transferGroups.entries)
      NowGroup(
        key: "server:$folder",
        folder: transfers.first.parentPath,
        transfers: transfers,
        completed: finished[folder] ?? 0,
        rate: live.folderRate(folder),
      ),
  ];
});
