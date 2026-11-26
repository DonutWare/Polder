import "package:polder_core/services/storage/preferences_store.dart";

const launchedAtLoginArgument = "--launched-at-login";

abstract interface class LaunchAtLogin {
  Future<bool?> isEnabled();

  Future<void> setEnabled(bool enabled);

  Future<bool> launchedAtLogin(List<String> arguments);
}

class LaunchMinimizedPreference {
  const LaunchMinimizedPreference(this._store);

  static const _key = "polder.launchAtLogin";

  final PreferencesStore _store;

  Future<bool> read() async => (await _store.readJson(_key))?["minimized"] as bool? ?? false;

  Future<void> write(bool minimized) => _store.writeJson(_key, {"minimized": minimized});
}
