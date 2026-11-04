import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/service_providers.dart" show preferencesStoreProvider;
import "package:polder/providers/update/update_preferences_provider.dart";
import "package:polder/providers/update/update_provider.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/services/update/update_feed.dart";
import "package:polder/services/update/update_manifest.dart";
import "package:polder/services/update/update_platform.dart";
import "package:polder/util/build_channel.dart";

import "../services/update/update_fixtures.dart";

class FakeUpdateFeed implements UpdateFeed {
  final Map<BuildChannel, UpdateManifest?> manifests = {};
  final List<BuildChannel> fetched = [];

  @override
  Future<UpdateManifest?> fetch(BuildChannel channel) async {
    fetched.add(channel);
    return manifests[channel];
  }
}

class FakeUpdatePlatform implements UpdatePlatform {
  bool inPlace = true;
  final List<int> downloaded = [];
  final List<({String path, bool relaunch})> installed = [];

  @override
  UpdateTarget? get target => UpdateTarget.macos;

  @override
  Future<bool> canInstallInPlace() async => inPlace;

  @override
  Future<String> download(UpdateManifest manifest, {required void Function(double progress) onProgress}) async {
    downloaded.add(manifest.build);
    onProgress(1);
    return "/updates/${manifest.build}/Polder.zip";
  }

  @override
  Future<void> install(String path, {required bool relaunch}) async => installed.add((path: path, relaunch: relaunch));
}

void main() {
  late FakeUpdateFeed feed;
  late FakeUpdatePlatform platform;
  late InMemoryPreferencesStore preferences;

  setUp(() {
    feed = FakeUpdateFeed();
    platform = FakeUpdatePlatform();
    preferences = InMemoryPreferencesStore();
  });

  ProviderContainer container({BuildChannel channel = BuildChannel.stable, UpdateFeed? withFeed}) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        buildChannelProvider.overrideWithValue(channel),
        preferencesStoreProvider.overrideWithValue(preferences),
        updateFeedProvider.overrideWithValue(withFeed ?? feed),
        updatePlatformProvider.overrideWithValue(platform),
        currentBuildProvider.overrideWith((ref) async => 10),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test("is off for development builds", () {
    expect(container(channel: BuildChannel.dev).read(updateProvider).phase, UpdatePhase.disabled);
  });

  test("reports up to date when no newer build exists", () async {
    final updates = container();
    feed.manifests[BuildChannel.stable] = manifest(build: 10);

    await updates.read(updateProvider.notifier).check();

    expect(updates.read(updateProvider).phase, UpdatePhase.upToDate);
    expect(feed.fetched, [BuildChannel.stable]);
  });

  test("downloads a newer build in the background and installs it on quit", () async {
    final updates = container();
    feed.manifests[BuildChannel.stable] = manifest(build: 12);

    await updates.read(updateProvider.notifier).check();
    await updates.read(updateProvider.notifier).installBeforeQuit(relaunch: false);

    expect(updates.read(updateProvider).phase, UpdatePhase.ready);
    expect(platform.downloaded, [12]);
    expect(platform.installed.single, (path: "/updates/12/Polder.zip", relaunch: false));
  });

  test("only offers nightly builds after opting in", () async {
    final updates = container();
    feed.manifests[BuildChannel.nightly] = manifest(channel: BuildChannel.nightly, build: 15);

    await updates.read(updateProvider.notifier).check();
    expect(updates.read(updateProvider).phase, UpdatePhase.upToDate);

    await updates.read(updatePreferencesProvider.notifier).setNightly(true);
    await pumpEventQueue();

    expect(updates.read(updateProvider).manifest?.build, 15);
    expect(feed.fetched, [BuildChannel.stable, BuildChannel.stable, BuildChannel.nightly]);
  });

  test("nightly builds keep following nightly by default", () async {
    final updates = container(channel: BuildChannel.nightly);

    expect((await updates.read(updatePreferencesProvider.future)).nightly, isTrue);
  });

  test("waits for the user when automatic updates are off", () async {
    final updates = container();
    feed.manifests[BuildChannel.stable] = manifest(build: 12);
    await updates.read(updatePreferencesProvider.notifier).setAutomatic(false);

    await updates.read(updateProvider.notifier).check();
    expect(updates.read(updateProvider).phase, UpdatePhase.available);
    expect(platform.downloaded, isEmpty);

    await updates.read(updateProvider.notifier).restartToUpdate();

    expect(updates.read(updateProvider).restartRequested, isTrue);
    expect(platform.downloaded, [12]);
  });

  test("only points to the download when it cannot replace itself", () async {
    final updates = container();
    platform.inPlace = false;
    feed.manifests[BuildChannel.stable] = manifest(build: 12);

    await updates.read(updateProvider.notifier).check();
    await updates.read(updateProvider.notifier).restartToUpdate();

    expect(updates.read(updateProvider).phase, UpdatePhase.available);
    expect(updates.read(updateProvider).restartRequested, isFalse);
    expect(platform.downloaded, isEmpty);
  });

  test("keeps the update it failed to download", () async {
    platform = _FailingDownloadPlatform();
    final updates = container();
    feed.manifests[BuildChannel.stable] = manifest(build: 12);

    await updates.read(updateProvider.notifier).check();

    expect(updates.read(updateProvider).phase, UpdatePhase.failed);
    expect(updates.read(updateProvider).manifest?.build, 12);
  });

  test("reports a failed check", () async {
    final updates = container(withFeed: _FailingFeed());

    await updates.read(updateProvider.notifier).check();

    expect(updates.read(updateProvider).phase, UpdatePhase.failed);
    expect(updates.read(updateProvider).manifest, isNull);
  });
}

class _FailingDownloadPlatform extends FakeUpdatePlatform {
  @override
  Future<String> download(UpdateManifest manifest, {required void Function(double progress) onProgress}) async =>
      throw const FileSystemException("disk full");
}

class _FailingFeed extends FakeUpdateFeed {
  @override
  Future<UpdateManifest?> fetch(BuildChannel channel) async => throw const UpdateFeedException("offline");
}
