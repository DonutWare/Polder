import "package:flutter_test/flutter_test.dart";

import "package:polder/services/update/update_manifest.dart";
import "package:polder/services/update/update_selector.dart";
import "package:polder/util/build_channel.dart";

import "update_fixtures.dart";

void main() {
  test("checks only the stable feed unless nightly builds are wanted", () {
    expect(feedsToCheck(nightly: false), [BuildChannel.stable]);
    expect(feedsToCheck(nightly: true), [BuildChannel.stable, BuildChannel.nightly]);
  });

  test("picks the newest build above the running one", () {
    final stable = manifest(build: 20);
    final nightly = manifest(channel: BuildChannel.nightly, build: 25);

    expect(selectUpdate(currentBuild: 10, target: UpdateTarget.macos, manifests: [stable, nightly]), nightly);
    expect(selectUpdate(currentBuild: 10, target: UpdateTarget.macos, manifests: [nightly, stable]), nightly);
  });

  test("moves a nightly user onto a stable release that is newer", () {
    final stable = manifest(build: 30);
    final nightly = manifest(channel: BuildChannel.nightly, build: 25);

    expect(selectUpdate(currentBuild: 25, target: UpdateTarget.linux, manifests: [stable, nightly]), stable);
  });

  test("never downgrades", () {
    expect(selectUpdate(currentBuild: 25, target: UpdateTarget.linux, manifests: [manifest(build: 20)]), isNull);
    expect(selectUpdate(currentBuild: 20, target: UpdateTarget.linux, manifests: [manifest(build: 20)]), isNull);
  });

  test("skips missing feeds and builds without an asset for this platform", () {
    final windowsOnly = manifest(build: 40, targets: {UpdateTarget.windows});

    expect(selectUpdate(currentBuild: 10, target: UpdateTarget.macos, manifests: [null, windowsOnly]), isNull);
    expect(selectUpdate(currentBuild: 10, target: UpdateTarget.windows, manifests: [null, windowsOnly]), windowsOnly);
  });
}
