import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/security.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/auth/single_sign_on.dart";

final linkedIdentitiesProvider = AsyncNotifierProvider.autoDispose<LinkedIdentitiesNotifier, List<LinkedIdentity>>(
  LinkedIdentitiesNotifier.new,
);

class LinkedIdentitiesNotifier extends AsyncNotifier<List<LinkedIdentity>> {
  @override
  Future<List<LinkedIdentity>> build() => ref.watch(polderApiProvider).linkedIdentities();

  Future<void> link(String providerId) async {
    final api = ref.read(polderApiProvider);
    final result = await SingleSignOn.link(
      ({required redirectUri, required codeChallenge}) =>
          api.startLinkingIdentity(providerId, redirectUri: redirectUri, codeChallenge: codeChallenge),
    );
    await api.confirmLinkingIdentity(code: result.code, codeVerifier: result.verifier);
    await _reload();
  }

  Future<void> unlink(LinkedIdentity identity) async {
    await ref.read(polderApiProvider).unlinkIdentity(identity.id);
    await _reload();
  }

  Future<void> _reload() async {
    if (!ref.mounted) return;
    ref.invalidateSelf();
    await ref.read(currentUserProvider.notifier).refresh();
  }
}
