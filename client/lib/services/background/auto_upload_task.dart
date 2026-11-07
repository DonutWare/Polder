import "package:flutter/widgets.dart";

import "package:workmanager/workmanager.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/services/background/background_scheduler.dart";
import "package:polder/services/background/background_session.dart";
import "package:polder/services/background/notification_action_handler.dart";
import "package:polder/services/background/notification_check_task.dart";
import "package:polder/services/notifications/device_localizations.dart";
import "package:polder/services/notifications/notification_preferences_store.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:polder/services/notifications/plugin_notification_service.dart";
import "package:polder/services/notifications/upload_notifier.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/services/sync/drift/drift_sync_state_store.dart";
import "package:polder/services/sync/native_sync_platform.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/services/sync/sync_engine.dart";
import "package:polder/services/sync/sync_pause.dart";
import "package:polder/services/sync/sync_state_store.dart";

@pragma("vm:entry-point")
void backgroundCallbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, _) async {
    final notifications = await PluginNotificationService.initialize(
      onBackgroundResponse: notificationActionDispatcher,
    );
    final credentials = platformCredentialsStore();
    final store = SharedPreferencesStore();
    if (task == BackgroundScheduler.notificationsTask) {
      await NotificationCheckTask(credentials: credentials, notifications: notifications, store: store).run();
    } else {
      await AutoUploadTask(credentials: credentials, notifications: notifications, preferences: store).run();
    }
    return true;
  });
}

class AutoUploadTask {
  const AutoUploadTask({required this.credentials, required this.notifications, required this.preferences});

  final CredentialsStore credentials;
  final NotificationService notifications;
  final PreferencesStore preferences;

  Future<void> run() async {
    final store = DriftSyncStateStore(NativeSyncPlatform.openDatabase());
    try {
      final session = await BackgroundSession.open(credentials);
      if (session == null || await SyncPause.read(preferences)) return;
      final roots = [
        for (final root in await _autoUploadRoots(store))
          if (root.accountId == session.account.id) root,
      ];
      if (roots.isEmpty) return;
      final activity = SyncActivity();
      final notifier = UploadNotifier(
        notifications: notifications,
        preferences: await NotificationPreferencesStore.read(preferences),
        strings: deviceLocalizations(),
      );
      await notifier.checking();
      notifier.watch(activity.changes);
      final engine = SyncEngine(api: session.api, store: store, deviceName: session.deviceName, activity: activity);
      var report = const SyncRunReport();
      for (final root in roots) {
        report += await engine.run(root);
      }
      await notifier.finish(report);
    } finally {
      await store.close();
    }
  }

  Future<List<SyncRoot>> _autoUploadRoots(SyncStateStore store) async =>
      (await store.roots()).where((root) => root.enabled && root.mode == SyncMode.autoUpload).toList();
}
