import "dart:io";

import "package:polder/services/update/installer/update_installer.dart";

class LinuxUpdateInstaller implements UpdateInstaller {
  const LinuxUpdateInstaller();

  String? get _appImage => Platform.environment["APPIMAGE"];

  @override
  Future<bool> canInstallInPlace() async {
    final appImage = _appImage;
    if (appImage == null || !await File(appImage).exists()) return false;
    return isWritableDirectory(File(appImage).parent);
  }

  @override
  Future<void> install(File archive, {required bool relaunch}) async {
    final appImage = _appImage!;
    final replacement = await archive.copy("$appImage.update");
    await runChecked("chmod", ["755", replacement.path]);
    await replacement.rename(appImage);
    if (relaunch) await Process.start(appImage, const [], mode: ProcessStartMode.detached);
  }
}
