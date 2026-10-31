import "dart:io";

import "package:http/http.dart" as http;
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "package:polder/services/update/installer/linux_update_installer.dart";
import "package:polder/services/update/installer/macos_update_installer.dart";
import "package:polder/services/update/installer/update_installer.dart";
import "package:polder/services/update/installer/windows_update_installer.dart";
import "package:polder/services/update/update_downloader.dart";
import "package:polder/services/update/update_manifest.dart";
import "package:polder/services/update/update_platform.dart";

UpdatePlatform createUpdatePlatform(http.Client client) => NativeUpdatePlatform(client);

class NativeUpdatePlatform implements UpdatePlatform {
  NativeUpdatePlatform(http.Client client) : _downloader = UpdateDownloader(client, _updatesDirectory);

  final UpdateDownloader _downloader;

  @override
  final UpdateTarget? target = Platform.isMacOS
      ? UpdateTarget.macos
      : Platform.isWindows
      ? UpdateTarget.windows
      : Platform.isLinux
      ? UpdateTarget.linux
      : null;

  UpdateInstaller? get _installer => switch (target) {
    UpdateTarget.macos => const MacosUpdateInstaller(),
    UpdateTarget.windows => const WindowsUpdateInstaller(),
    UpdateTarget.linux => const LinuxUpdateInstaller(),
    null => null,
  };

  @override
  Future<bool> canInstallInPlace() async => await _installer?.canInstallInPlace() ?? false;

  @override
  Future<String> download(UpdateManifest manifest, {required void Function(double progress) onProgress}) async {
    final asset = manifest.assets[target];
    if (asset == null) throw UpdateDownloadException("No ${target?.name} asset in build ${manifest.build}");
    final file = await _downloader.download(manifest, asset, onProgress: onProgress);
    return file.path;
  }

  @override
  Future<void> install(String path, {required bool relaunch}) => _installer!.install(File(path), relaunch: relaunch);

  static Future<Directory> _updatesDirectory() async =>
      Directory(p.join((await getApplicationSupportDirectory()).path, "updates"));
}
