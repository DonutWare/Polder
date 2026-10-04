import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/server_settings.dart";
import "package:nomad/providers/nomad_api_provider.dart";

final serverSettingsProvider = AsyncNotifierProvider.autoDispose<ServerSettingsNotifier, ServerSettings>(
  ServerSettingsNotifier.new,
);

class ServerSettingsNotifier extends AsyncNotifier<ServerSettings> {
  @override
  Future<ServerSettings> build() => ref.watch(nomadApiProvider).serverSettings();

  Future<void> setTrashRetentionDays(int days) =>
      _update(() => ref.read(nomadApiProvider).updateServerSettings(trashRetentionDays: days));

  Future<void> setTrashRetentionEnforced(bool enforced) =>
      _update(() => ref.read(nomadApiProvider).updateServerSettings(trashRetentionEnforced: enforced));

  Future<void> _update(Future<ServerSettings> Function() change) async => state = AsyncData(await change());
}
