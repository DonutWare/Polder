import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/account.dart";
import "package:nomad/models/token_pair.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/storage/credentials_store.dart";

/// The signed-in account, or null when signed out.
final accountProvider = AsyncNotifierProvider<AccountNotifier, Account?>(AccountNotifier.new);

final currentAccountProvider = Provider<Account?>((ref) => ref.watch(accountProvider).value);

class AccountNotifier extends AsyncNotifier<Account?> {
  CredentialsStore get _store => ref.read(credentialsStoreProvider);

  @override
  Future<Account?> build() => _store.load();

  Future<void> signIn(Account account) async {
    // Let the stored account load first, or it would overwrite this one when it arrives.
    await future;
    state = AsyncData(account);
    await _store.save(account);
  }

  /// Stores refreshed tokens, unless [accountId] has been signed out in the meantime.
  Future<void> storeTokens(String accountId, TokenPair tokens) async {
    final account = state.value ?? await future;
    if (account?.id == accountId) await signIn(account!.withTokens(tokens));
  }

  /// Forgets [accountId] without telling the server, for a session the server already ended.
  Future<void> expire(String accountId) async {
    if ((state.value ?? await future)?.id == accountId) await _clear();
  }

  Future<void> signOut() async {
    final account = state.value ?? await future;
    if (account != null) await _revokeQuietly(account);
    await _clear();
  }

  Future<void> _clear() async {
    await future;
    state = const AsyncData(null);
    await _store.clear();
  }

  Future<void> _revokeQuietly(Account account) async {
    try {
      await ref.read(serverNomadApiProvider(account.serverUrl)).logout(account.refreshToken);
    } on ApiException {
      return;
    }
  }
}
