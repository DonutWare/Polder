import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/providers/service_providers.dart";

import "package:polder/services/features/feature_modes.dart";

final featureModesSeedProvider = Provider<FeatureModes>((_) => const FeatureModes({}));

final installedCompanionsSeedProvider = Provider<Set<PolderFeature>>((_) => const {});

final featureModesProvider = NotifierProvider<FeatureModesNotifier, FeatureModes>(FeatureModesNotifier.new);

class FeatureModesNotifier extends Notifier<FeatureModes> {
  @override
  FeatureModes build() => ref.watch(featureModesSeedProvider);

  Future<void> setMode(PolderFeature feature, FeatureMode mode) async {
    state = state.withMode(feature, mode);
    await FeatureModes.write(ref.read(preferencesStoreProvider), state);
  }
}

final installedCompanionsProvider = NotifierProvider<InstalledCompanionsNotifier, Set<PolderFeature>>(
  InstalledCompanionsNotifier.new,
);

class InstalledCompanionsNotifier extends Notifier<Set<PolderFeature>> {
  @override
  Set<PolderFeature> build() {
    if (FeatureModes.canOpenApps) unawaited(Future.microtask(refresh));
    return ref.watch(installedCompanionsSeedProvider);
  }

  Future<void> refresh() async {
    final installed = await FeatureModes.detectInstalled();
    if (!ref.mounted) return;
    if (installed.length != state.length || !installed.containsAll(state)) state = installed;
  }
}

final resolvedFeatureModesProvider = Provider<FeatureModes>(
  (ref) => ref.watch(featureModesProvider).resolve(ref.watch(installedCompanionsProvider)),
);
