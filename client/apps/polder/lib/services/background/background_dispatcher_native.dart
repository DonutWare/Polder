import "package:flutter/widgets.dart";

import "package:polder_core/services/storage/credentials_store.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_drive/services/background/auto_upload_task.dart";
import "package:polder_drive/services/background/background_scheduler.dart";
import "package:polder_drive/services/background/notification_action_handler.dart";
import "package:polder_ui/services/notifications/plugin_notification_service.dart";
import "package:workmanager/workmanager.dart";

import "package:polder/services/background/notification_check_task.dart";
import "package:polder/services/features/feature_modes.dart";

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
    } else if ((await FeatureModes.readResolved(store)).isBuiltIn(PolderFeature.drive)) {
      await AutoUploadTask(credentials: credentials, notifications: notifications, preferences: store).run();
    }
    return true;
  });
}
