import "package:flutter/foundation.dart";

import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/services/storage/preferences_store.dart";

abstract final class NotificationPreferencesStore {
  static const key = "polder.notifications";

  static NotificationPreferences get defaults => const NotificationPreferences(enabled: !kIsWeb);

  static Future<NotificationPreferences> read(PreferencesStore store) async {
    final json = await store.readJson(key);
    return json == null ? defaults : NotificationPreferences.fromJson(json);
  }

  static Future<void> write(PreferencesStore store, NotificationPreferences preferences) =>
      store.writeJson(key, preferences.toJson());
}
