import "package:polder/models/sync/auto_upload_settings.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/sync/in_memory_sync_state_store.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_platform.dart";
import "package:polder/services/sync/sync_service.dart";
import "package:polder/services/sync/sync_state_store.dart";

import "fake_sync_service.dart";

class FakeSyncPlatform implements SyncPlatform {
  final store = InMemorySyncStateStore();
  final service = FakeSyncService();
  final List<AutoUploadSettings> scheduled = [];
  bool storageAccess = true;
  bool hasFiles = false;

  @override
  bool get supportsSync => true;

  @override
  bool get supportsFolderSync => true;

  @override
  bool get supportsAutoUpload => true;

  @override
  Future<SyncStateStore> openStore() async => store;

  @override
  SyncService createService({
    required PolderApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  }) => service;

  @override
  Stream<String> watchFolder(String localPath) => const Stream.empty();

  @override
  Future<bool> requestStorageAccess() async => storageAccess;

  @override
  Future<bool> containsFiles(String localPath) async => hasFiles;

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) async => scheduled.add(settings);
}
