import "package:polder/services/update/update_manifest.dart";

abstract interface class UpdatePlatform {
  UpdateTarget? get target;

  Future<bool> canInstallInPlace();

  Future<String> download(UpdateManifest manifest, {required void Function(double progress) onProgress});

  Future<void> install(String path, {required bool relaunch});
}
