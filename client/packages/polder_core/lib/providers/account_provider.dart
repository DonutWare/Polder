import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/models/token_pair.dart";
import "package:polder_core/models/user.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_core/services/storage/credentials_store.dart";

/// The signed-in account, or null when signed out.
final accountProvider = AsyncNotifierProvider<AccountNotifier, Account?>(AccountNotifier.new);

final currentAccountProvider = Provider<Account?>((ref) => ref.watch(accountProvider).value);

final sessionEndedProvider = Provider<bool>(
  (ref) => ref.watch(currentAccountProvider.select((account) => account?.sessionEnded ?? false)),
);

final continueOfflineProvider = NotifierProvider<ContinueOfflineNotifier, bool>(ContinueOfflineNotifier.new);

class ContinueOfflineNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.watch(sessionEndedProvider);
    return false;
  }

  void continueOffline() => state = ref.read(sessionEndedProvider);

  void signInAgain() => state = false;
}

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

  Future<void> storeTokens(String accountId, TokenPair tokens) =>
      _updateStored((account) => account.id == accountId ? account.withTokens(tokens) : null);

  Future<void> storeUser(User user) => _updateStored(
    (account) => account.user.id == user.id && account.user != user ? account.copyWith(user: user) : null,
  );

  Future<void> _updateStored(Account? Function(Account account) change) async {
    final current = state.value ?? await future;
    final stored = await _store.load();
    final base = stored?.id == current?.id ? stored : null;
    final updated = base == null ? null : change(base);
    if (updated == null || state.value?.id != updated.id) return;
    state = AsyncData(updated);
    await _store.save(updated);
  }

  Future<void> endSession(String accountId) =>
      _updateStored((account) => account.id == accountId && !account.sessionEnded ? account.endSession() : null);

  Future<void> signOut() async {
    final account = state.value ?? await future;
    if (account != null && !account.sessionEnded) await _revokeQuietly(account);
    await _clear();
  }

  Future<void> _clear() async {
    await future;
    state = const AsyncData(null);
    await _store.clear();
  }

  Future<void> _revokeQuietly(Account account) async {
    try {
      await ref.read(serverPolderApiProvider(account.serverUrl)).logout(account.refreshToken);
    } on ApiException {
      return;
    }
  }
}
