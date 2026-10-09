import "package:flutter/material.dart";

import "package:dynamic_color/dynamic_color.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/appearance.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/storage/preferences_store.dart";

final appearanceProvider = NotifierProvider<AppearanceNotifier, Appearance>(AppearanceNotifier.new);

typedef SystemAccentReader = Future<Color?> Function();

final systemAccentReaderProvider = Provider<SystemAccentReader>((ref) => readSystemAccent);

Future<Color?> readSystemAccent() async {
  try {
    final palette = await DynamicColorPlugin.getCorePalette();
    if (palette != null) return Color(palette.primary.get(40));
  } catch (_) {}
  return null;
}

class AppearanceNotifier extends Notifier<Appearance> {
  static const _key = "polder.appearance";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  @override
  Appearance build() {
    ref.listen(currentAccountProvider.select((account) => account?.user), (_, user) => _adopt(user));
    _load();
    return const Appearance();
  }

  Future<void> _load() async {
    final saved = await _preferences.readJson(_key);
    final mode = ThemeMode.values.asNameMap()[saved?["mode"]];
    final accent = saved?["accent"];
    if (!ref.mounted) return;
    state = state.copyWith(mode: mode ?? state.mode, accent: accent is int ? Color(accent) : null);
    await _adopt(ref.read(currentAccountProvider)?.user);
    await refreshSystemAccent();
  }

  Future<void> _adopt(User? user) async {
    if (user == null || !user.hasChosenAppearance) return;
    final adopted = state.copyWith(mode: user.theme ?? ThemeMode.system, accent: user.accent);
    if (adopted == state) return;
    state = adopted;
    await _save();
  }

  Future<void> refreshSystemAccent() async {
    final color = await ref.read(systemAccentReaderProvider)();
    if (ref.mounted && color != state.systemAccent) state = state.copyWith(systemAccent: color);
  }

  Future<void> setMode(ThemeMode mode) => _choose(state.copyWith(mode: mode));

  Future<void> setAccent(Color? accent) => _choose(state.copyWith(accent: accent));

  Future<void> _choose(Appearance chosen) async {
    state = chosen;
    await _save();
    if (ref.read(currentAccountProvider) == null) return;
    await ref.read(currentUserProvider.notifier).saveAppearance(theme: chosen.mode, accent: chosen.accent);
  }

  Future<void> _save() => _preferences.writeJson(_key, {
    "mode": state.mode.name,
    if (state.accent != null) "accent": state.accent!.toARGB32(),
  });
}
