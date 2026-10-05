import "package:polder/models/account.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/services/api/auth_session.dart";
import "package:polder/services/storage/credentials_store.dart";

class StoredAuthSession implements AuthSession {
  StoredAuthSession({required this._store, required this.accountId, required this._accessToken});

  final CredentialsStore _store;
  final String accountId;
  String? _accessToken;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<String?> readRefreshToken() async => (await _signedIn())?.refreshToken;

  @override
  Future<void> storeTokens(TokenPair tokens) async {
    _accessToken = tokens.accessToken;
    final account = await _signedIn();
    if (account != null) await _store.save(account.withTokens(tokens));
  }

  @override
  Future<void> expire() async => _accessToken = null;

  Future<Account?> _signedIn() async {
    final account = await _store.load();
    return account?.id == accountId ? account : null;
  }
}
