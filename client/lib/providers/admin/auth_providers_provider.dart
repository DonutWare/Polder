import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/security.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/providers/polder_api_provider.dart";

final authProviderPresetsProvider = FutureProvider.autoDispose<List<AuthProviderPreset>>(
  (ref) => ref.watch(polderApiProvider).authProviderPresets(),
);

final authProvidersProvider = AsyncNotifierProvider.autoDispose<AuthProvidersNotifier, List<AuthProvider>>(
  AuthProvidersNotifier.new,
);

class AuthProvidersNotifier extends AsyncNotifier<List<AuthProvider>> {
  @override
  Future<List<AuthProvider>> build() => ref.watch(polderApiProvider).authProviders();

  Future<AuthProvider> create(NewAuthProvider provider) async {
    final created = await ref.read(polderApiProvider).createAuthProvider(provider);
    await _reload();
    return created;
  }

  Future<void> change(String id, AuthProviderChanges changes) async {
    await ref.read(polderApiProvider).updateAuthProvider(id, changes);
    await _reload();
  }

  Future<void> delete(String id) async {
    await ref.read(polderApiProvider).deleteAuthProvider(id);
    await _reload();
  }

  Future<void> reorder(List<AuthProvider> ordered) async {
    final api = ref.read(polderApiProvider);
    state = AsyncData(ordered);
    try {
      state = AsyncData(await api.reorderAuthProviders([for (final provider in ordered) provider.id]));
    } on Object {
      ref.invalidateSelf();
      rethrow;
    }
    await _refreshBranding();
  }

  Future<String?> test(String id) => ref.read(polderApiProvider).testAuthProvider(id);

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
    await _refreshBranding();
  }

  Future<void> _refreshBranding() async {
    final branding = ref.read(brandingProvider);
    if (branding.serverUrl case final serverUrl?) await ref.read(brandingProvider.notifier).load(serverUrl);
  }
}
