import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";

abstract interface class SyncPlatform {
  bool get supportsSync;

  bool get supportsFolderSync;

  bool get supportsAutoUpload;

  Future<SyncStateStore> openStore();

  SyncService createService({
    required NomadApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  });

  Stream<String> watchFolder(String localPath);

  Future<bool> requestStorageAccess();

  Future<bool> containsFiles(String localPath);

  Future<void> scheduleAutoUpload(AutoUploadSettings settings);
}
