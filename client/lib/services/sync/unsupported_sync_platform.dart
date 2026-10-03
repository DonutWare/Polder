import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/sync_platform.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";

SyncPlatform createSyncPlatform() => const UnsupportedSyncPlatform();

Future<void> initializeBackgroundSync() async {}

class UnsupportedSyncPlatform implements SyncPlatform {
  const UnsupportedSyncPlatform();

  @override
  bool get supportsSync => false;

  @override
  bool get supportsFolderSync => false;

  @override
  bool get supportsAutoUpload => false;

  @override
  Future<SyncStateStore> openStore() => throw UnsupportedError("Sync is not available on this platform");

  @override
  SyncService createService({required NomadApi api, required SyncStateStore store, required String deviceName}) =>
      throw UnsupportedError("Sync is not available on this platform");

  @override
  Stream<void> watchFolder(String localPath) => const Stream.empty();

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) async {}
}
