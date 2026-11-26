import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/models/token_pair.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/api/api_client_factory.dart";
import "package:polder_core/services/api/auth_session.dart";
import "package:polder_core/services/api/polder_api.dart";

final serverPolderApiProvider = Provider.family<PolderApi, String>(
  (ref, serverUrl) => PolderApi(ApiClientFactory.create(serverUrl, httpClient: ref.watch(httpClientProvider))),
);

final polderApiProvider = Provider<PolderApi>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl));
  if (accountId == null || serverUrl == null) throw StateError("No account is signed in");
  final session = AccountAuthSession(ref, accountId);
  return PolderApi(
    ApiClientFactory.create(
      serverUrl,
      session: session,
      deviceName: ref.watch(deviceNameProvider),
      httpClient: ref.watch(httpClientProvider),
      onReachability: ({required reachable}) {
        if (ref.mounted) ref.read(serverConnectionProvider.notifier).report(reachable: reachable);
      },
    ),
  );
});

class AccountAuthSession implements AuthSession {
  const AccountAuthSession(this._ref, this.accountId);

  final Ref _ref;
  final String accountId;

  AccountNotifier get _account => _ref.read(accountProvider.notifier);

  @override
  String? get accessToken => _signedIn(_ref.read(accountProvider).value)?.usableAccessToken;

  @override
  Future<String?> readRefreshToken() async {
    final stored = await _ref.read(credentialsStoreProvider).load();
    return _signedIn(stored)?.usableRefreshToken;
  }

  @override
  Future<void> storeTokens(TokenPair tokens) => _account.storeTokens(accountId, tokens);

  @override
  Future<void> endSession() => _account.endSession(accountId);

  Account? _signedIn(Account? account) => account?.id == accountId ? account : null;
}
