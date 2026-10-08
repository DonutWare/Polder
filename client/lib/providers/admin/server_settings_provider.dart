import "dart:ui";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/branding.dart";
import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/text_extraction_status_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/providers/polder_api_provider.dart";

final serverSettingsProvider = AsyncNotifierProvider.autoDispose<ServerSettingsNotifier, ServerSettings>(
  ServerSettingsNotifier.new,
);

class ServerSettingsNotifier extends AsyncNotifier<ServerSettings> {
  @override
  Future<ServerSettings> build() => ref.watch(polderApiProvider).serverSettings();

  Future<void> setTrashRetentionDays(int days) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(trashRetentionDays: days));

  Future<void> setTrashRetentionEnforced(bool enforced) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(trashRetentionEnforced: enforced));

  Future<void> setSearchContentEnabled(bool enabled) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(searchContentEnabled: enabled));

  Future<void> setOcrEnabled(bool enabled) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(ocrEnabled: enabled));

  Future<void> setOcrLanguages(List<String> languages) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(ocrLanguages: languages));

  Future<void> setOcrMaxPages(int pages) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(ocrMaxPages: pages));

  Future<void> setInstanceName(String name) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(instanceName: name));

  Future<void> setWelcomeMessage(String message) =>
      _update(() => ref.read(polderApiProvider).updateServerSettings(welcomeMessage: message));

  Future<void> setAccentColor(Color? color) => _update(
    () => ref.read(polderApiProvider).updateServerSettings(accentColor: color == null ? "" : hexColor(color)),
  );

  Future<void> _update(Future<ServerSettings> Function() change) async {
    state = AsyncData(await change());
    ref.invalidate(textExtractionStatusProvider);
    await ref.read(brandingProvider.notifier).refresh();
  }
}
