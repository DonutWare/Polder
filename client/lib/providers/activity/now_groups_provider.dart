import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/activity/activity_scope_provider.dart";
import "package:nomad/providers/activity/live_transfers_provider.dart";
import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/providers/sync/sync_activity_provider.dart";
import "package:nomad/providers/sync/sync_paused_provider.dart";
import "package:nomad/services/sync/sync_activity.dart";

class NowGroup {
  const NowGroup({
    required this.key,
    required this.folder,
    this.local = const [],
    this.transfers = const [],
    this.completed = 0,
  });

  final String key;
  final String folder;
  final List<PendingUpload> local;
  final List<LiveTransfer> transfers;
  final int completed;

  int get active => local.length + transfers.length;

  int get totalFiles => active + completed;

  bool get isBatch => totalFiles >= 2;

  int get uploading => local.where((upload) => upload.phase == LocalSyncPhase.uploading).length + transfers.length;

  int get preparing => local.where((upload) => upload.phase == LocalSyncPhase.preparing).length;

  int get waiting => local.where((upload) => upload.phase == LocalSyncPhase.waiting).length;

  int get rate => [
    ...local.map((upload) => upload.rate),
    ...transfers.map((transfer) => transfer.rate),
  ].fold(0, (sum, rate) => sum + rate);

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
  final device = ref.watch(currentAccountProvider.select((account) => account?.deviceName)) ?? "";
  final paused = ref.watch(syncPausedProvider).value ?? false;
  final items = scope.includes(selfId, selfId: selfId)
      ? ref.watch(localSyncItemsProvider).values.toList()
      : const <LocalSyncItem>[];
  final completed = ref.read(syncActivityProvider).completed;

  final localGroups = <String, List<LocalSyncItem>>{};
  for (final item in items) {
    localGroups.putIfAbsent(item.group, () => []).add(item);
  }
  final localPaths = {for (final item in items) item.remotePath};
  final transferGroups = <String, List<LiveTransfer>>{};
  for (final transfer in ref.watch(scopedTransfersProvider)) {
    if (transfer.userId == selfId && localPaths.contains(transfer.path)) continue;
    transferGroups.putIfAbsent(LiveTransfersNotifier.folderKey(transfer), () => []).add(transfer);
  }
  final finished = ref.read(liveTransfersProvider.notifier).finishedByFolder;

  return [
    for (final MapEntry(key: group, value: members) in localGroups.entries)
      NowGroup(
        key: "local:$group",
        folder: members.first.groupRemotePath,
        local: [
          for (final item in members..sort((a, b) => a.relativePath.compareTo(b.relativePath)))
            PendingUpload.local(item, device: device, paused: paused),
        ],
        completed: completed[group] ?? 0,
      ),
    for (final MapEntry(key: folder, value: transfers) in transferGroups.entries)
      NowGroup(
        key: "server:$folder",
        folder: transfers.first.parentPath,
        transfers: transfers,
        completed: finished[folder] ?? 0,
      ),
  ];
});
