import "dart:io";

import "package:path/path.dart" as p;

import "package:polder/services/update/installer/update_installer.dart";

class WindowsUpdateInstaller implements UpdateInstaller {
  const WindowsUpdateInstaller();

  @override
  Future<bool> canInstallInPlace() async {
    final localAppData = Platform.environment["LOCALAPPDATA"];
    if (localAppData == null) return false;
    final installed = p.join(localAppData, "Programs", "Polder");
    return p.isWithin(installed.toLowerCase(), Platform.resolvedExecutable.toLowerCase());
  }

  @override
  Future<void> install(File archive, {required bool relaunch}) async {
    final arguments = ["'/VERYSILENT'", "'/SUPPRESSMSGBOXES'", "'/NORESTART'", if (relaunch) "'/RELAUNCH=1'"];
    final command =
        "Wait-Process -Id $pid -ErrorAction SilentlyContinue; "
        "Start-Process -FilePath ${_quoted(archive.path)} -ArgumentList ${arguments.join(",")}";
    await Process.start("powershell.exe", [
      "-NoProfile",
      "-NonInteractive",
      "-WindowStyle",
      "Hidden",
      "-Command",
      command,
    ], mode: ProcessStartMode.detached);
  }

  static String _quoted(String value) => "'${value.replaceAll("'", "''")}'";
}
