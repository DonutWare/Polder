import "dart:io";

import "package:workmanager/workmanager.dart";

import "package:polder/models/sync/auto_upload_settings.dart";
import "package:polder/services/background/auto_upload_task.dart";

abstract final class BackgroundScheduler {
  static const autoUploadTask = "org.knaapen.polder.autoUpload";
  static const notificationsTask = "org.knaapen.polder.notifications";
  static const _frequency = Duration(minutes: 15);

  static bool get _isSupported => Platform.isAndroid || Platform.isIOS;

  static Future<void> initialize() async {
    if (_isSupported) await Workmanager().initialize(backgroundCallbackDispatcher);
  }

  static Future<void> scheduleAutoUpload(AutoUploadSettings settings) async {
    if (!_isSupported) return;
    if (!settings.enabled) return Workmanager().cancelByUniqueName(autoUploadTask);
    await Workmanager().registerPeriodicTask(
      autoUploadTask,
      autoUploadTask,
      frequency: _frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: settings.wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        requiresCharging: settings.chargingOnly,
      ),
    );
  }

  static Future<void> scheduleNotificationChecks({required bool enabled}) async {
    if (!_isSupported) return;
    if (!enabled) return Workmanager().cancelByUniqueName(notificationsTask);
    await Workmanager().registerPeriodicTask(
      notificationsTask,
      notificationsTask,
      frequency: _frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
