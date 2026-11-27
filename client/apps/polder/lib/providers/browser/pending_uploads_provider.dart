import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/activity.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/transfer.dart";
import "package:polder_core/providers/browser/file_operations_provider.dart";
import "package:polder/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder_core/providers/offline/offline_changes_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder_core/util/remote_path.dart";

class PendingUpload {
  const PendingUpload({
    required this.path,
    required this.bytes,
    this.total,
    this.rate = 0,
    this.phase = LocalSyncPhase.uploading,
    this.paused = false,
  });

  final String path;
  final int bytes;
  final int? total;
  final int rate;
  factory PendingUpload.local(LocalSyncItem item, {bool paused = false}) => PendingUpload(
    path: item.remotePath,
    bytes: item.bytes,
    total: item.total,
    rate: item.rate,
    phase: item.phase,
    paused: paused,
  );

  final LocalSyncPhase phase;

  final bool paused;

  String get name => RemotePath.name(path);

  double? get progress {
    if (phase == LocalSyncPhase.waiting) return 0;
    final expected = total;
    return expected == null || expected <= 0 ? null : (bytes / expected).clamp(0.0, 1.0);
  }
}

class BrowserItem {
  const BrowserItem({this.entry, this.pending, this.pendingFolder, this.syncing, this.operation, this.arriving})
    : assert(entry != null || pending != null || pendingFolder != null || arriving != null);

  final FileEntry? entry;
  final PendingUpload? pending;

  final String? pendingFolder;

  final TransferDirectionKind? syncing;

  final EntryOperation? operation;

  final ArrivingItem? arriving;

  String get name => entry?.name ?? pending?.name ?? pendingFolder ?? arriving!.name;

  bool get isDir => entry?.isDir ?? (pendingFolder != null || (arriving?.isDir ?? false));

  BrowserItem withOperation(EntryOperation operation) =>
      BrowserItem(entry: entry, pending: pending, pendingFolder: pendingFolder, syncing: syncing, operation: operation);
}

final pendingUploadsProvider = Provider.autoDispose.family<List<PendingUpload>, String>((ref, path) {
  final ownUploads = ref.watch(transfersProvider).where((transfer) => transfer.direction == TransferDirection.upload);
  final ownIds = {for (final transfer in ownUploads) transfer.clientId};
  final syncing = ref.watch(localSyncItemsProvider).values.where((item) => RemotePath.parent(item.remotePath) == path);
  final syncingPaths = {for (final item in syncing) item.remotePath};
  final paused = ref.watch(syncPausedProvider).value ?? false;
  return [
    for (final item in syncing) PendingUpload.local(item, paused: paused),
    for (final transfer in ownUploads)
      if (transfer.isRunning && transfer.remotePath != null && RemotePath.parent(transfer.remotePath!) == path)
        PendingUpload(
          path: transfer.remotePath!,
          bytes: transfer.transferred,
          total: transfer.total > 0 ? transfer.total : null,
          rate: transfer.rate,
        ),
    for (final change in ref.watch(offlineChangesProvider))
      if (change.group != OfflineChangeGroup.calendar &&
          change.kind == OfflineChangeKind.edited &&
          RemotePath.parent(change.key) == path &&
          !syncingPaths.contains(change.key))
        PendingUpload(path: change.key, bytes: 0, phase: LocalSyncPhase.waiting),
    for (final transfer in ref.watch(uploadsIntoDirectoryProvider(path)))
      if (!ownIds.contains(transfer.clientId) && !syncingPaths.contains(transfer.path))
        PendingUpload(path: transfer.path, bytes: transfer.bytes, total: transfer.total, rate: transfer.rate),
  ];
});

List<BrowserItem> mergePendingUploads(
  List<FileEntry> sortedEntries,
  List<PendingUpload> pending, {
  Map<String, TransferDirectionKind> busyFolders = const {},
}) {
  final byName = {for (final upload in pending) upload.name: upload};
  final items = [
    for (final entry in sortedEntries)
      BrowserItem(
        entry: entry,
        pending: entry.isDir ? null : byName.remove(entry.name),
        syncing: entry.isDir ? busyFolders[entry.name] : null,
      ),
  ];
  final existing = {for (final entry in sortedEntries) entry.name};
  for (final folder in busyFolders.keys.toSet().difference(existing).toList()..sort()) {
    final key = folder.toLowerCase();
    final index = items.indexWhere((item) => !item.isDir || item.name.toLowerCase().compareTo(key) > 0);
    items.insert(index == -1 ? items.length : index, BrowserItem(pendingFolder: folder, syncing: busyFolders[folder]));
  }
  for (final upload in byName.values) {
    final key = upload.name.toLowerCase();
    final index = items.indexWhere((item) => !item.isDir && item.name.toLowerCase().compareTo(key) > 0);
    items.insert(index == -1 ? items.length : index, BrowserItem(pending: upload));
  }
  return items;
}

List<BrowserItem> mergeFileOperations(
  List<BrowserItem> items, {
  required Map<String, EntryOperation> busy,
  required List<ArrivingItem> arriving,
}) {
  if (busy.isEmpty && arriving.isEmpty) return items;
  final merged = <BrowserItem>[];
  for (final item in items) {
    final operation = busy[item.name];
    if (operation == null || item.entry == null) {
      merged.add(item);
    } else if (!_leaves(operation)) {
      merged.add(item.withOperation(operation));
    }
  }
  final present = {for (final item in merged) item.name};
  for (final incoming in arriving) {
    if (!present.add(incoming.name)) continue;
    final key = incoming.name.toLowerCase();
    final index = merged.indexWhere(
      (item) => incoming.isDir
          ? !item.isDir || item.name.toLowerCase().compareTo(key) > 0
          : !item.isDir && item.name.toLowerCase().compareTo(key) > 0,
    );
    merged.insert(index == -1 ? merged.length : index, BrowserItem(arriving: incoming));
  }
  return merged;
}

bool _leaves(EntryOperation operation) =>
    operation.state == FileOperationItemState.done &&
    switch (operation.kind) {
      FileOperationKind.move || FileOperationKind.delete || FileOperationKind.rename => true,
      _ => false,
    };
