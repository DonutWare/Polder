import "dart:io";

import "package:drift_flutter/drift_flutter.dart";
import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/services/background/auto_upload_scheduler.dart";
import "package:nomad/services/sync/drift/drift_sync_state_store.dart";
import "package:nomad/services/sync/drift/sync_database.dart";
import "package:nomad/services/sync/folder_watcher.dart";
import "package:nomad/services/sync/sync_activity.dart";
import "package:nomad/services/sync/sync_engine.dart";
import "package:nomad/services/sync/sync_platform.dart";
import "package:nomad/services/sync/sync_service.dart";
import "package:nomad/services/sync/sync_state_store.dart";
import "package:path_provider/path_provider.dart";

SyncPlatform createSyncPlatform() => const NativeSyncPlatform();

Future<void> initializeBackgroundSync() => AutoUploadScheduler.initialize();

class NativeSyncPlatform implements SyncPlatform {
  const NativeSyncPlatform();

  static const databaseName = "nomad_sync";

  static SyncDatabase openDatabase() => SyncDatabase(
    driftDatabase(
      name: databaseName,
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    ),
  );

  @override
  bool get supportsSync => true;

  @override
  bool get supportsFolderSync => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  bool get supportsAutoUpload => Platform.isAndroid || Platform.isIOS;

  @override
  Future<SyncStateStore> openStore() async => DriftSyncStateStore(openDatabase());

  @override
  SyncService createService({
    required NomadApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  }) => SyncEngine(api: api, store: store, deviceName: deviceName, activity: activity);

  @override
  Stream<String> watchFolder(String localPath) => FolderWatcher.watch(localPath);

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) => AutoUploadScheduler.schedule(settings);
}
