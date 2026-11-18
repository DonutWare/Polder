import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/service_providers.dart";
import "package:polder/services/desktop/launch_at_login.dart";

typedef LaunchAtLoginSettings = ({bool enabled, bool minimized});

final launchAtLoginSettingsProvider = AsyncNotifierProvider<LaunchAtLoginNotifier, LaunchAtLoginSettings?>(
  LaunchAtLoginNotifier.new,
);

class LaunchAtLoginNotifier extends AsyncNotifier<LaunchAtLoginSettings?> {
  LaunchMinimizedPreference get _minimized => LaunchMinimizedPreference(ref.read(preferencesStoreProvider));

  @override
  Future<LaunchAtLoginSettings?> build() async {
    final enabled = await ref.watch(launchAtLoginProvider)?.isEnabled();
    if (enabled == null) return null;
    return (enabled: enabled, minimized: await _minimized.read());
  }

  Future<void> setEnabled(bool enabled) async {
    final launchAtLogin = ref.read(launchAtLoginProvider);
    final current = state.value;
    if (launchAtLogin == null || current == null) return;
    state = AsyncData((enabled: enabled, minimized: current.minimized));
    try {
      await launchAtLogin.setEnabled(enabled);
    } on Exception {
      state = AsyncData(current);
    }
  }

  Future<void> setMinimized(bool minimized) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData((enabled: current.enabled, minimized: minimized));
    await _minimized.write(minimized);
  }
}
