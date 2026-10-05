import "dart:io";

import "package:drift_flutter/drift_flutter.dart";
import "package:polder/models/sync/auto_upload_settings.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/background/auto_upload_scheduler.dart";
import "package:polder/services/sync/drift/drift_sync_state_store.dart";
import "package:polder/services/sync/drift/sync_database.dart";
import "package:polder/services/sync/folder_watcher.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_engine.dart";
import "package:polder/services/sync/sync_platform.dart";
import "package:polder/services/sync/sync_service.dart";
import "package:polder/services/sync/sync_state_store.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";

SyncPlatform createSyncPlatform() => const NativeSyncPlatform();

Future<void> initializeBackgroundSync() => AutoUploadScheduler.initialize();

class NativeSyncPlatform implements SyncPlatform {
  const NativeSyncPlatform();

  static const databaseName = "polder_sync";

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
    required PolderApi api,
    required SyncStateStore store,
    required String deviceName,
    SyncActivity? activity,
  }) => SyncEngine(api: api, store: store, deviceName: deviceName, activity: activity);

  @override
  Stream<String> watchFolder(String localPath) => FolderWatcher.watch(localPath);

  @override
  Future<bool> requestStorageAccess() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.request().isGranted) return true;
    final statuses = await [Permission.photos, Permission.videos, Permission.storage].request();
    bool allowed(Permission permission) =>
        statuses[permission]?.isGranted == true || statuses[permission]?.isLimited == true;
    return allowed(Permission.storage) || (allowed(Permission.photos) && allowed(Permission.videos));
  }

  @override
  Future<bool> containsFiles(String localPath) async {
    final directory = Directory(localPath);
    if (!await directory.exists()) return false;
    return directory.list(recursive: true, followLinks: false).any((entity) => entity is File);
  }

  @override
  Future<void> scheduleAutoUpload(AutoUploadSettings settings) => AutoUploadScheduler.schedule(settings);
}
