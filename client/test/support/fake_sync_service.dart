import "dart:async";

import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/services/sync/sync_service.dart";

class FakeSyncService implements SyncService {
  final List<(String, ConflictResolution)> resolved = [];
  SyncRunReport nextReport = const SyncRunReport();
  final List<Set<String>> pausedPathsSeen = [];
  Completer<void>? gate;
  final List<String> skippedRoots = [];

  @override
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}}) async {
    pausedPathsSeen.add(pausedPaths);
    await gate?.future;
    return nextReport;
  }

  @override
  Future<void> skipExisting(SyncRoot root) async => skippedRoots.add(root.id);

  @override
  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution) async =>
      resolved.add((conflict.relativePath, resolution));
}
