import "package:polder_core/models/sync/auto_upload_settings.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder_drive/services/sync/sync_activity.dart";
import "package:polder_drive/services/sync/sync_platform.dart";
import "package:polder_drive/services/sync/sync_service.dart";
import "package:polder_drive/services/sync/sync_state_store.dart";

SyncPlatform createSyncPlatform() => const UnsupportedSyncPlatform();

Future<void> initializeBackgroundSync(void Function() dispatcher) async {}

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
  SyncService createService({
    required PolderApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  }) => throw UnsupportedError("Sync is not available on this platform");

  @override
  Stream<String> watchFolder(String localPath) => const Stream.empty();

  @override
  Future<bool> requestStorageAccess() async => false;

  @override
  Future<bool> containsFiles(String localPath) async => false;

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) async {}

  @override
  Future<void> scheduleNotificationChecks({required bool enabled}) async {}
}
