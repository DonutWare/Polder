import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/account.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/auth_session.dart";
import "package:polder/services/api/polder_api.dart";

final serverPolderApiProvider = Provider.family<PolderApi, String>(
  (ref, serverUrl) => PolderApi(ApiClientFactory.create(serverUrl, httpClient: ref.watch(httpClientProvider))),
);

final polderApiProvider = Provider<PolderApi>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl));
  if (accountId == null || serverUrl == null) throw StateError("No account is signed in");
  final session = AccountAuthSession(ref, accountId);
  return PolderApi(ApiClientFactory.create(serverUrl, session: session, httpClient: ref.watch(httpClientProvider)));
});

class AccountAuthSession implements AuthSession {
  const AccountAuthSession(this._ref, this.accountId);

  final Ref _ref;
  final String accountId;

  AccountNotifier get _account => _ref.read(accountProvider.notifier);

  @override
  String? get accessToken => _signedIn(_ref.read(accountProvider).value)?.accessToken;

  @override
  Future<String?> readRefreshToken() async {
    final stored = await _ref.read(credentialsStoreProvider).load();
    return _signedIn(stored)?.refreshToken;
  }

  @override
  Future<void> storeTokens(TokenPair tokens) => _account.storeTokens(accountId, tokens);

  @override
  Future<void> expire() => _account.expire(accountId);

  Account? _signedIn(Account? account) => account?.id == accountId ? account : null;
}
