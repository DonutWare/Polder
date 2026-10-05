import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/sync/auto_upload_settings.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";

final autoUploadSettingsProvider = AsyncNotifierProvider<AutoUploadSettingsNotifier, AutoUploadSettings>(
  AutoUploadSettingsNotifier.new,
);

final autoUploadAllowedProvider = FutureProvider.autoDispose<bool>((ref) async {
  final conditions = ref.watch(deviceConditionsProvider);
  final settings = await ref.watch(autoUploadSettingsProvider.future);
  if (!settings.enabled) return false;
  if (settings.wifiOnly && !await conditions.isOnUnmeteredNetwork()) return false;
  return !settings.chargingOnly || await conditions.isCharging();
});

class AutoUploadSettingsNotifier extends AsyncNotifier<AutoUploadSettings> {
  static const _key = "polder.autoUpload";

  @override
  Future<AutoUploadSettings> build() async {
    final json = await ref.watch(preferencesStoreProvider).readJson(_key);
    return json == null ? const AutoUploadSettings() : AutoUploadSettings.fromJson(json);
  }

  Future<void> setEnabled(bool enabled) => _update((settings) => settings.copyWith(enabled: enabled));

  Future<void> setWifiOnly(bool wifiOnly) => _update((settings) => settings.copyWith(wifiOnly: wifiOnly));

  Future<void> setChargingOnly(bool chargingOnly) =>
      _update((settings) => settings.copyWith(chargingOnly: chargingOnly));

  Future<void> _update(AutoUploadSettings Function(AutoUploadSettings current) change) async {
    final next = change(state.value ?? await future);
    state = AsyncData(next);
    await ref.read(preferencesStoreProvider).writeJson(_key, next.toJson());
    await ref.read(syncPlatformProvider).scheduleAutoUpload(next);
  }
}
