import "package:polder/services/update/update_manifest.dart";
import "package:polder/util/build_channel.dart";

List<BuildChannel> feedsToCheck({required bool nightly}) => [BuildChannel.stable, if (nightly) BuildChannel.nightly];

UpdateManifest? selectUpdate({
  required int currentBuild,
  required UpdateTarget target,
  required Iterable<UpdateManifest?> manifests,
}) {
  UpdateManifest? newest;
  for (final manifest in manifests.nonNulls) {
    if (manifest.build <= currentBuild || !manifest.assets.containsKey(target)) continue;
    if (newest == null || manifest.build > newest.build) newest = manifest;
  }
  return newest;
}
