import "package:flutter/material.dart";

import "package:dynamic_color/dynamic_color.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:nomad/models/appearance.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/services/storage/preferences_store.dart";

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
  static const _key = "nomad.appearance";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  @override
  Appearance build() {
    _load();
    return const Appearance();
  }

  Future<void> _load() async {
    final saved = await _preferences.readJson(_key);
    final mode = ThemeMode.values.asNameMap()[saved?["mode"]];
    final accent = saved?["accent"];
    if (!ref.mounted) return;
    state = state.copyWith(mode: mode ?? state.mode, accent: accent is int ? Color(accent) : null);
    await refreshSystemAccent();
  }

  Future<void> refreshSystemAccent() async {
    final color = await ref.read(systemAccentReaderProvider)();
    if (ref.mounted && color != state.systemAccent) state = state.copyWith(systemAccent: color);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _save();
  }

  Future<void> setAccent(Color? accent) async {
    state = state.copyWith(accent: accent);
    await _save();
  }

  Future<void> _save() => _preferences.writeJson(_key, {
    "mode": state.mode.name,
    if (state.accent != null) "accent": state.accent!.toARGB32(),
  });
}
