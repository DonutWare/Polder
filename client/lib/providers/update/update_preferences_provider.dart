import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/service_providers.dart";
import "package:polder/util/build_channel.dart";

final buildChannelProvider = Provider<BuildChannel>((ref) => currentBuildChannel);

class UpdatePreferences {
  const UpdatePreferences({required this.nightly, required this.automatic});

  final bool nightly;
  final bool automatic;

  UpdatePreferences copyWith({bool? nightly, bool? automatic}) =>
      UpdatePreferences(nightly: nightly ?? this.nightly, automatic: automatic ?? this.automatic);

  Map<String, dynamic> toJson() => {"nightly": nightly, "automatic": automatic};

  @override
  bool operator ==(Object other) =>
      other is UpdatePreferences && other.nightly == nightly && other.automatic == automatic;

  @override
  int get hashCode => Object.hash(nightly, automatic);
}

final updatePreferencesProvider = AsyncNotifierProvider<UpdatePreferencesNotifier, UpdatePreferences>(
  UpdatePreferencesNotifier.new,
);

class UpdatePreferencesNotifier extends AsyncNotifier<UpdatePreferences> {
  static const _key = "polder.updates";

  @override
  Future<UpdatePreferences> build() async {
    final stored = await ref.read(preferencesStoreProvider).readJson(_key);
    return UpdatePreferences(
      nightly: stored?["nightly"] as bool? ?? ref.read(buildChannelProvider) == BuildChannel.nightly,
      automatic: stored?["automatic"] as bool? ?? true,
    );
  }

  Future<void> setNightly(bool nightly) => _save((preferences) => preferences.copyWith(nightly: nightly));

  Future<void> setAutomatic(bool automatic) => _save((preferences) => preferences.copyWith(automatic: automatic));

  Future<void> _save(UpdatePreferences Function(UpdatePreferences preferences) change) async {
    final next = change(await future);
    state = AsyncData(next);
    await ref.read(preferencesStoreProvider).writeJson(_key, next.toJson());
  }
}
