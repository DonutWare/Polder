import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:polder/models/account.dart";
import "package:polder/services/storage/preferences_store.dart";

abstract interface class CredentialsStore {
  Future<Account?> load();

  Future<void> save(Account account);

  Future<void> clear();
}

const _accountKey = "polder.account";

CredentialsStore platformCredentialsStore() => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
    ? PreferencesCredentialsStore(SharedPreferencesStore())
    : const SecureCredentialsStore();

class SecureCredentialsStore implements CredentialsStore {
  const SecureCredentialsStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<Account?> load() async {
    final raw = await _storage.read(key: _accountKey);
    if (raw == null || raw.isEmpty) return null;
    return Account.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Account account) => _storage.write(key: _accountKey, value: jsonEncode(account.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _accountKey);
}

class PreferencesCredentialsStore implements CredentialsStore {
  const PreferencesCredentialsStore(this._preferences);

  final PreferencesStore _preferences;

  @override
  Future<Account?> load() async {
    final json = await _preferences.readJson(_accountKey);
    return json == null ? null : Account.fromJson(json);
  }

  @override
  Future<void> save(Account account) => _preferences.writeJson(_accountKey, account.toJson());

  @override
  Future<void> clear() => _preferences.remove(_accountKey);
}

class InMemoryCredentialsStore implements CredentialsStore {
  InMemoryCredentialsStore([this._account]);

  Account? _account;

  @override
  Future<Account?> load() async => _account;

  @override
  Future<void> save(Account account) async => _account = account;

  @override
  Future<void> clear() async => _account = null;
}
