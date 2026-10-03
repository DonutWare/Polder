import "dart:io";

import "package:workmanager/workmanager.dart";

import "package:nomad/models/sync/auto_upload_settings.dart";
import "package:nomad/services/background/auto_upload_task.dart";

abstract final class AutoUploadScheduler {
  static const taskName = "org.knaapen.nomad.autoUpload";
  static const _frequency = Duration(minutes: 15);

  static bool get _isSupported => Platform.isAndroid;

  static Future<void> initialize() async {
    if (_isSupported) await Workmanager().initialize(autoUploadCallbackDispatcher);
  }

  static Future<void> schedule(AutoUploadSettings settings) async {
    if (!_isSupported) return;
    if (!settings.enabled) return Workmanager().cancelByUniqueName(taskName);
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: _frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: settings.wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        requiresCharging: settings.chargingOnly,
      ),
    );
  }
}
