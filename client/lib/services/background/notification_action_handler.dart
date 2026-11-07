import "dart:async";
import "dart:ui";

import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:polder/services/background/background_session.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/share_notifications.dart";
import "package:polder/services/storage/credentials_store.dart";

@pragma("vm:entry-point")
void notificationActionDispatcher(NotificationResponse response) {
  DartPluginRegistrant.ensureInitialized();
  unawaited(respondInBackground(NotificationTap.decode(response.payload, response.actionId)));
}

Future<void> respondInBackground(NotificationTap tap) async {
  if (!ShareNotifications.handles(tap)) return;
  final session = await BackgroundSession.open(platformCredentialsStore());
  if (session != null) await ShareNotifications.respond(session.api, tap);
}
