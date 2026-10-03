import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/account.dart";
import "package:nomad/models/token_pair.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/services/api/api_client_factory.dart";
import "package:nomad/services/api/auth_session.dart";
import "package:nomad/services/api/nomad_api.dart";

final serverNomadApiProvider = Provider.family<NomadApi, String>(
  (ref, serverUrl) => NomadApi(ApiClientFactory.create(serverUrl, httpClient: ref.watch(httpClientProvider))),
);

final nomadApiProvider = Provider<NomadApi>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl));
  if (accountId == null || serverUrl == null) throw StateError("No account is signed in");
  final session = AccountAuthSession(ref, accountId);
  return NomadApi(ApiClientFactory.create(serverUrl, session: session, httpClient: ref.watch(httpClientProvider)));
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
