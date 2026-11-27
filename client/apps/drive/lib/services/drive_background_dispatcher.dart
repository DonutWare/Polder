import "package:flutter/widgets.dart";

import "package:polder_core/services/storage/credentials_store.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_drive/services/background/auto_upload_task.dart";
import "package:polder_drive/services/background/background_scheduler.dart";
import "package:polder_drive/services/background/background_session.dart";
import "package:polder_drive/services/background/notification_action_handler.dart";
import "package:polder_drive/services/notifications/notification_feed.dart";
import "package:polder_ui/services/notifications/device_localizations.dart";
import "package:polder_ui/services/notifications/plugin_notification_service.dart";
import "package:workmanager/workmanager.dart";

@pragma("vm:entry-point")
void driveBackgroundDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, _) async {
    final notifications = await PluginNotificationService.initialize(
      onBackgroundResponse: notificationActionDispatcher,
      windows: WindowsNotificationIdentity.drive,
    );
    final credentials = platformCredentialsStore();
    final store = SharedPreferencesStore();
    if (task == BackgroundScheduler.notificationsTask) {
      final session = await BackgroundSession.open(credentials);
      if (session == null) return true;
      await NotificationFeed(
        api: session.api,
        store: store,
        notifications: notifications,
        strings: deviceLocalizations(),
        accountId: session.account.id,
      ).poll();
    } else {
      await AutoUploadTask(credentials: credentials, notifications: notifications, preferences: store).run();
    }
    return true;
  });
}
