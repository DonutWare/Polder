import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:polder/models/account.dart";

abstract interface class CredentialsStore {
  Future<Account?> load();

  Future<void> save(Account account);

  Future<void> clear();
}

class SecureCredentialsStore implements CredentialsStore {
  const SecureCredentialsStore([this._storage = const FlutterSecureStorage(mOptions: _macOptions)]);

  // The data protection keychain needs a team-signed build with a keychain-access-groups
  // entitlement; the legacy file-based keychain works for ad-hoc signed builds too.
  static const _macOptions = MacOsOptions(usesDataProtectionKeychain: false);

  static const _key = "polder.account";

  final FlutterSecureStorage _storage;

  @override
  Future<Account?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    return Account.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Account account) => _storage.write(key: _key, value: jsonEncode(account.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
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
