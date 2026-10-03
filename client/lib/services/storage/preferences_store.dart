import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

abstract interface class PreferencesStore {
  Future<Map<String, dynamic>?> readJson(String key);

  Future<void> writeJson(String key, Map<String, dynamic> value);
}

class SharedPreferencesStore implements PreferencesStore {
  SharedPreferencesStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await _preferences.getString(key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) => _preferences.setString(key, jsonEncode(value));
}

class InMemoryPreferencesStore implements PreferencesStore {
  final Map<String, Map<String, dynamic>> _values = {};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async => _values[key];

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async => _values[key] = value;
}
