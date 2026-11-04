import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "package:polder/providers/app/package_info_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/update/update_preferences_provider.dart";
import "package:polder/services/update/update_feed.dart";
import "package:polder/services/update/update_manifest.dart";
import "package:polder/services/update/update_platform.dart";
import "package:polder/services/update/update_platform_factory.dart";
import "package:polder/services/update/update_selector.dart";

final _updateHttpClientProvider = Provider<http.Client>((ref) {
  final shared = ref.watch(httpClientProvider);
  if (shared != null) return shared;
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final updatePlatformProvider = Provider<UpdatePlatform>(
  (ref) => createUpdatePlatform(ref.watch(_updateHttpClientProvider)),
);

final updateFeedProvider = Provider<UpdateFeed?>((ref) => UpdateFeed.tryCreate(ref.watch(_updateHttpClientProvider)));

final currentBuildProvider = FutureProvider<int>(
  (ref) async => int.tryParse((await ref.watch(packageInfoProvider.future)).buildNumber) ?? 0,
);

enum UpdatePhase { disabled, idle, checking, upToDate, available, downloading, ready, failed }

class UpdateState {
  const UpdateState(
    this.phase, {
    this.manifest,
    this.inPlace = false,
    this.progress = 0,
    this.path,
    this.restartRequested = false,
  });

  final UpdatePhase phase;
  final UpdateManifest? manifest;
  final bool inPlace;
  final double progress;
  final String? path;
  final bool restartRequested;

  bool get busy => phase == UpdatePhase.checking || phase == UpdatePhase.downloading;
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(UpdateNotifier.new);

class UpdateNotifier extends Notifier<UpdateState> {
  static const startupDelay = Duration(seconds: 30);
  static const interval = Duration(hours: 6);

  @override
  UpdateState build() {
    final enabled =
        ref.watch(buildChannelProvider).receivesUpdates &&
        ref.watch(updateFeedProvider) != null &&
        ref.watch(updatePlatformProvider).target != null;
    if (!enabled) return const UpdateState(UpdatePhase.disabled);

    final startup = Timer(startupDelay, () => unawaited(check()));
    final periodic = Timer.periodic(interval, (_) => unawaited(check()));
    ref.onDispose(() {
      startup.cancel();
      periodic.cancel();
    });
    ref.listen(updatePreferencesProvider.select((preferences) => preferences.value), (previous, next) {
      if (previous != null && next != null && previous != next) unawaited(_check(next));
    });
    return const UpdateState(UpdatePhase.idle);
  }

  Future<void> check() async => _check(await ref.read(updatePreferencesProvider.future));

  Future<void> _check(UpdatePreferences preferences) async {
    if (state.phase == UpdatePhase.disabled || state.busy || state.phase == UpdatePhase.ready) return;
    state = const UpdateState(UpdatePhase.checking);
    final UpdateManifest? manifest;
    try {
      manifest = await _newest(nightly: preferences.nightly);
    } catch (_) {
      state = const UpdateState(UpdatePhase.failed);
      return;
    }
    if (manifest == null) {
      state = const UpdateState(UpdatePhase.upToDate);
      return;
    }
    try {
      final inPlace = await ref.read(updatePlatformProvider).canInstallInPlace();
      if (inPlace && preferences.automatic) {
        await _download(manifest);
      } else {
        state = UpdateState(UpdatePhase.available, manifest: manifest, inPlace: inPlace);
      }
    } catch (_) {
      state = UpdateState(UpdatePhase.failed, manifest: manifest);
    }
  }

  Future<void> restartToUpdate() async {
    final manifest = state.manifest;
    if (state.phase == UpdatePhase.available && state.inPlace && manifest != null) {
      try {
        await _download(manifest);
      } catch (_) {
        state = UpdateState(UpdatePhase.failed, manifest: manifest);
      }
    }
    if (state.phase != UpdatePhase.ready) return;
    state = UpdateState(
      UpdatePhase.ready,
      manifest: state.manifest,
      inPlace: true,
      path: state.path,
      restartRequested: true,
    );
  }

  void cancelRestart() {
    if (!state.restartRequested) return;
    state = UpdateState(UpdatePhase.ready, manifest: state.manifest, inPlace: true, path: state.path);
  }

  Future<void> installBeforeQuit({required bool relaunch}) async {
    final path = state.path;
    if (state.phase != UpdatePhase.ready || path == null) return;
    try {
      await ref.read(updatePlatformProvider).install(path, relaunch: relaunch);
    } on Exception {
      state = UpdateState(UpdatePhase.failed, manifest: state.manifest);
    }
  }

  Future<UpdateManifest?> _newest({required bool nightly}) async {
    final feed = ref.read(updateFeedProvider)!;
    final platform = ref.read(updatePlatformProvider);
    final manifests = await Future.wait(feedsToCheck(nightly: nightly).map(feed.fetch));
    return selectUpdate(
      currentBuild: await ref.read(currentBuildProvider.future),
      target: platform.target!,
      manifests: manifests,
    );
  }

  Future<void> _download(UpdateManifest manifest) async {
    state = UpdateState(UpdatePhase.downloading, manifest: manifest, inPlace: true);
    final path = await ref
        .read(updatePlatformProvider)
        .download(
          manifest,
          onProgress: (progress) {
            if ((progress * 100).floor() == (state.progress * 100).floor()) return;
            state = UpdateState(UpdatePhase.downloading, manifest: manifest, inPlace: true, progress: progress);
          },
        );
    state = UpdateState(UpdatePhase.ready, manifest: manifest, inPlace: true, path: path);
  }
}
