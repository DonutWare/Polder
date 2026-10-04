import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/models/server_event.dart";
import "package:nomad/providers/activity/activity_scope_provider.dart";
import "package:nomad/providers/realtime/events_provider.dart";
import "package:nomad/providers/sync/sync_activity_provider.dart";
import "package:nomad/util/remote_path.dart";

final liveTransfersProvider = NotifierProvider<LiveTransfersNotifier, Map<String, LiveTransfer>>(
  LiveTransfersNotifier.new,
);

class LiveTransfersNotifier extends Notifier<Map<String, LiveTransfer>> {
  final Map<String, int> _finished = {};

  Map<String, int> get finishedByFolder => Map.unmodifiable(_finished);

  static String folderKey(LiveTransfer transfer) => "${transfer.userId}:${transfer.parentPath}";

  @override
  Map<String, LiveTransfer> build() {
    _finished.clear();
    final client = ref.watch(eventsClientProvider);
    if (client != null) {
      final subscription = client.events.listen(apply);
      ref.onDispose(subscription.cancel);
    }
    return const {};
  }

  void apply(ServerEvent event) {
    switch (event) {
      case SnapshotEvent(:final transfers):
        _finished.clear();
        state = {for (final transfer in transfers) transfer.id: transfer};
      case DisconnectedEvent():
        _finished.clear();
        state = const {};
      case TransferEvent(phase: TransferPhase.finished, :final transfer):
        final remaining = {...state}..remove(transfer.id);
        final folder = folderKey(transfer);
        if (remaining.values.any((other) => folderKey(other) == folder)) {
          _finished.update(folder, (count) => count + 1, ifAbsent: () => 1);
        } else {
          _finished.remove(folder);
        }
        state = remaining;
      case TransferEvent(:final transfer):
        state = {...state, transfer.id: transfer};
      default:
    }
  }
}

final scopedTransfersProvider = Provider<List<LiveTransfer>>((ref) {
  final scope = ref.watch(activityScopeProvider);
  final selfId = ref.watch(selfUserIdProvider) ?? 0;
  return ref
      .watch(liveTransfersProvider)
      .values
      .where((transfer) => scope.includes(transfer.userId, selfId: selfId))
      .toList()
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
});

final ownUploadsProvider = Provider<List<LiveTransfer>>((ref) {
  final selfId = ref.watch(selfUserIdProvider);
  return ref
      .watch(liveTransfersProvider)
      .values
      .where((transfer) => transfer.isUpload && transfer.userId == selfId)
      .toList();
});

final uploadsIntoDirectoryProvider = Provider.autoDispose.family<List<LiveTransfer>, String>(
  (ref, path) => ref.watch(ownUploadsProvider).where((transfer) => transfer.parentPath == path).toList(),
);

final incomingPathsProvider = Provider<Set<String>>(
  (ref) => {
    for (final transfer in ref.watch(ownUploadsProvider)) transfer.path,
    for (final item in ref.watch(localSyncItemsProvider).values) item.remotePath,
  },
);

final busyFoldersProvider = Provider.autoDispose.family<Set<String>, String>((ref, path) {
  final names = <String>{};
  for (final incoming in ref.watch(incomingPathsProvider)) {
    final relative = RemotePath.relativeTo(RemotePath.parent(incoming), path);
    if (relative != null) names.add(RemotePath.segments(relative).first);
  }
  return names;
});
