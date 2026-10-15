import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/activity.dart";
import "package:polder/models/server_event.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/throughput_meter.dart";

final liveTransfersProvider = NotifierProvider<LiveTransfersNotifier, Map<String, LiveTransfer>>(
  LiveTransfersNotifier.new,
);

class LiveTransfersNotifier extends Notifier<Map<String, LiveTransfer>> {
  final Map<String, int> _finished = {};
  final Map<String, ThroughputMeter> _folderMeters = {};
  final Map<String, int> _bytesSeen = {};

  Map<String, int> get finishedByFolder => Map.unmodifiable(_finished);

  int folderRate(String folder) => _folderMeters[folder]?.rate ?? 0;

  static String folderKey(LiveTransfer transfer) => "${transfer.userId}:${transfer.parentPath}";

  @override
  Map<String, LiveTransfer> build() {
    _finished.clear();
    _forgetRates();
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
        _forgetRates();
        for (final transfer in transfers) {
          _bytesSeen[transfer.id] = transfer.bytes;
        }
        state = {for (final transfer in transfers) transfer.id: transfer};
      case DisconnectedEvent():
        _finished.clear();
        _forgetRates();
        state = const {};
      case TransferEvent(phase: TransferPhase.finished, :final transfer):
        _measure(transfer);
        _bytesSeen.remove(transfer.id);
        final remaining = {...state}..remove(transfer.id);
        final folder = folderKey(transfer);
        if (remaining.values.any((other) => folderKey(other) == folder)) {
          _finished.update(folder, (count) => count + 1, ifAbsent: () => 1);
        } else {
          _finished.remove(folder);
          _folderMeters.remove(folder);
        }
        state = remaining;
      case TransferEvent(:final transfer):
        _measure(transfer);
        state = {...state, transfer.id: transfer};
      default:
    }
  }

  void _measure(LiveTransfer transfer) {
    final previous = _bytesSeen[transfer.id] ?? 0;
    _bytesSeen[transfer.id] = transfer.bytes;
    _folderMeters.putIfAbsent(folderKey(transfer), ThroughputMeter.new).add(transfer.bytes - previous);
  }

  void _forgetRates() {
    _folderMeters.clear();
    _bytesSeen.clear();
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
    for (final item in ref.watch(localSyncItemsProvider).values)
      if (!item.isDownload) item.remotePath,
  },
);

final outgoingPathsProvider = Provider<Set<String>>(
  (ref) => {
    for (final item in ref.watch(localSyncItemsProvider).values)
      if (item.isDownload) item.remotePath,
  },
);

final busyFoldersProvider = Provider.autoDispose.family<Map<String, TransferDirectionKind>, String>((ref, path) {
  final folders = <String, TransferDirectionKind>{};
  void mark(Set<String> paths, TransferDirectionKind direction) {
    for (final busy in paths) {
      final relative = RemotePath.relativeTo(RemotePath.parent(busy), path);
      if (relative != null) folders.putIfAbsent(RemotePath.segments(relative).first, () => direction);
    }
  }

  mark(ref.watch(incomingPathsProvider), TransferDirectionKind.upload);
  mark(ref.watch(outgoingPathsProvider), TransferDirectionKind.download);
  return folders;
});
