import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:polder_account_link/shared_account.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_core/util/flavor.dart";

abstract interface class CredentialsStore {
  Future<Account?> load();

  Future<void> save(Account account);

  Future<void> clear();

  Stream<void> get changes;
}

const _accountKey = "polder.account";

const sharedAccountNamespace = isDevFlavor ? "org.knaapen.polder.dev" : "org.knaapen.polder";

CredentialsStore platformCredentialsStore() {
  final appStore = _appCredentialsStore();
  return SharedAccount.isSupported
      ? SharedAccountCredentialsStore(const SharedAccount(sharedAccountNamespace), appStore)
      : appStore;
}

CredentialsStore _appCredentialsStore() => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
    ? PreferencesCredentialsStore(SharedPreferencesStore())
    : const SecureCredentialsStore();

class SharedAccountCredentialsStore implements CredentialsStore {
  const SharedAccountCredentialsStore(this._shared, this._appStore);

  final SharedAccount _shared;
  final CredentialsStore _appStore;

  @override
  Future<Account?> load() async {
    final String? stored;
    try {
      stored = await _shared.read();
    } on Exception catch (error) {
      if (!_isPlatformFailure(error)) rethrow;
      return _appStore.load();
    }
    if (stored != null) return _decode(stored);
    return _promoteAppAccount();
  }

  @override
  Future<void> save(Account account) async {
    try {
      await _shared.write(name: account.handle, json: jsonEncode(account.toJson()));
    } on Exception catch (error) {
      if (!_isPlatformFailure(error)) rethrow;
      await _appStore.save(account);
    }
  }

  @override
  Future<void> clear() async {
    await _appStore.clear();
    try {
      await _shared.remove();
    } on Exception catch (error) {
      if (!_isPlatformFailure(error)) rethrow;
    }
  }

  @override
  Stream<void> get changes => _shared.changes;

  Future<Account?> takeSuperseded() async {
    final appAccount = await _appStore.load();
    if (appAccount == null) return null;
    final Account? shared;
    try {
      final stored = await _shared.read();
      shared = stored == null ? null : _decode(stored);
    } on Exception catch (error) {
      if (!_isPlatformFailure(error)) rethrow;
      return null;
    }
    if (shared == null) return null;
    await _appStore.clear();
    return appAccount.refreshToken == shared.refreshToken ? null : appAccount;
  }

  Future<Account?> _promoteAppAccount() async {
    final appAccount = await _appStore.load();
    if (appAccount == null) return null;
    try {
      await _shared.write(name: appAccount.handle, json: jsonEncode(appAccount.toJson()));
    } on Exception catch (error) {
      if (!_isPlatformFailure(error)) rethrow;
      return appAccount;
    }
    await _appStore.clear();
    return appAccount;
  }

  static Account _decode(String stored) => Account.fromJson(jsonDecode(stored) as Map<String, dynamic>);

  static bool _isPlatformFailure(Exception error) => error is PlatformException || error is MissingPluginException;
}

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

  @override
  Stream<void> get changes => const Stream.empty();
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

  @override
  Stream<void> get changes => const Stream.empty();
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

  @override
  Stream<void> get changes => const Stream.empty();
}
