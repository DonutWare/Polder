import "dart:async";

import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/services/sync/sync_service.dart";

class FakeSyncService implements SyncService {
  final List<(String, ConflictResolution)> resolved = [];
  SyncRunReport nextReport = const SyncRunReport();
  final List<Set<String>> pausedPathsSeen = [];
  Completer<void>? gate;

  @override
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}}) async {
    pausedPathsSeen.add(pausedPaths);
    await gate?.future;
    return nextReport;
  }

  @override
  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution) async =>
      resolved.add((conflict.relativePath, resolution));
}
