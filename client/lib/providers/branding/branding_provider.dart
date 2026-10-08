import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/branding.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/util/branding_images.dart";

/// The branding of the signed-in server, or of the server the login screen is connecting to.
final brandingProvider = NotifierProvider<BrandingNotifier, Branding>(BrandingNotifier.new);

class BrandingNotifier extends Notifier<Branding> {
  static const _key = "polder.branding";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  String? _loading;

  @override
  Branding build() {
    final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl));
    if (serverUrl != null) Future.microtask(() => load(serverUrl));
    return const Branding();
  }

  /// Shows the cached branding for [serverUrl] right away, then what the server says now.
  Future<void> load(String serverUrl) async {
    _loading = serverUrl;
    final cached = await _readCache(serverUrl);
    if (!_stillLoading(serverUrl)) return;
    if (cached != null) {
      state = cached;
    } else if (state.serverUrl != serverUrl) {
      state = Branding(serverUrl: serverUrl);
    }
    try {
      final fresh = await ref.read(serverPolderApiProvider(serverUrl)).branding();
      if (!_stillLoading(serverUrl)) return;
      state = fresh.copyWith(serverUrl: serverUrl);
      await _writeCache(state);
    } on ApiException {
      return;
    }
  }

  Future<void> refresh() async {
    final serverUrl = state.serverUrl;
    if (serverUrl != null) await load(serverUrl);
  }

  void clear() {
    _loading = null;
    state = const Branding();
  }

  Future<void> setIcon(Uint8List bytes) async {
    await ref.read(polderApiProvider).setBrandingIcon(await shrinkIcon(bytes));
    await refresh();
  }

  Future<void> removeIcon() async {
    await ref.read(polderApiProvider).removeBrandingIcon();
    await refresh();
  }

  Future<void> addBackground(Uint8List bytes) async {
    await ref.read(polderApiProvider).addBrandingBackground(bytes);
    await refresh();
  }

  Future<void> removeBackground(String id) async {
    await ref.read(polderApiProvider).removeBrandingBackground(id);
    await refresh();
  }

  bool _stillLoading(String serverUrl) => ref.mounted && _loading == serverUrl;

  Future<Branding?> _readCache(String serverUrl) async {
    final saved = await _preferences.readJson(_key);
    if (saved == null) return null;
    final cached = Branding.fromJson(saved);
    return cached.serverUrl == serverUrl ? cached : null;
  }

  Future<void> _writeCache(Branding branding) => _preferences.writeJson(_key, branding.toJson());
}
