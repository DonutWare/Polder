import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/models/sync/sync_status.dart";

abstract interface class SyncService {
  Future<SyncRunReport> run(SyncRoot root, {Set<String> pausedPaths = const {}});

  /// Marks what is in [root] now as handled, so an upload-only root only picks up files added from here on.
  Future<void> skipExisting(SyncRoot root);

  Future<void> resolve(SyncRoot root, Conflict conflict, ConflictResolution resolution);
}
