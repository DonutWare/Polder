import "package:polder/services/storage/preferences_store.dart";

abstract final class SyncPause {
  static const preferenceKey = "polder.syncPaused";

  static Future<bool> read(PreferencesStore preferences) async =>
      (await preferences.readJson(preferenceKey))?["paused"] == true;

  static Future<void> write(PreferencesStore preferences, {required bool paused}) =>
      preferences.writeJson(preferenceKey, {"paused": paused});
}
