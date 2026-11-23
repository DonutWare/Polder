import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/security.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/polder_api_provider.dart";

final twoFactorProvider = AsyncNotifierProvider.autoDispose<TwoFactorNotifier, TwoFactorState>(TwoFactorNotifier.new);

class TwoFactorNotifier extends AsyncNotifier<TwoFactorState> {
  @override
  Future<TwoFactorState> build() => ref.watch(polderApiProvider).twoFactor();

  Future<TwoFactorSetup> begin(String password) => ref.read(polderApiProvider).beginTwoFactorSetup(password);

  Future<List<String>> confirm(String code) => ref.read(polderApiProvider).confirmTwoFactorSetup(code);

  Future<void> finishSetup() => _reload();

  Future<List<String>> regenerate(String password) async {
    final codes = await ref.read(polderApiProvider).regenerateRecoveryCodes(password);
    await _reload();
    return codes;
  }

  Future<void> disable(String password) async {
    await ref.read(polderApiProvider).disableTwoFactor(password);
    await _reload();
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await ref.read(currentUserProvider.notifier).refresh();
  }
}
