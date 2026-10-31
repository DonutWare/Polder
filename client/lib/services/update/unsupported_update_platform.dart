import "package:http/http.dart" as http;

import "package:polder/services/update/update_manifest.dart";
import "package:polder/services/update/update_platform.dart";

UpdatePlatform createUpdatePlatform(http.Client client) => const UnsupportedUpdatePlatform();

class UnsupportedUpdatePlatform implements UpdatePlatform {
  const UnsupportedUpdatePlatform();

  @override
  UpdateTarget? get target => null;

  @override
  Future<bool> canInstallInPlace() async => false;

  @override
  Future<String> download(UpdateManifest manifest, {required void Function(double progress) onProgress}) =>
      throw UnsupportedError("Updates are not available on this platform");

  @override
  Future<void> install(String path, {required bool relaunch}) =>
      throw UnsupportedError("Updates are not available on this platform");
}
