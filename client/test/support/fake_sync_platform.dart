import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/sync/in_memory_sync_state_store.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_platform.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";

import "fake_sync_service.dart";

class FakeSyncPlatform implements SyncPlatform {
  final store = InMemorySyncStateStore();
  final service = FakeSyncService();
  final List<AutoUploadSettings> scheduled = [];

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
    required NomadApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  }) => service;

  @override
  Stream<String> watchFolder(String localPath) => const Stream.empty();

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) async => scheduled.add(settings);
}
