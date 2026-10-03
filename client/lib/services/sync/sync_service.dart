import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";

abstract interface class SyncService {
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}});

  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution);
}
