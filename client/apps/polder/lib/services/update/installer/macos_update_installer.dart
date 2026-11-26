import "dart:io";

import "package:path/path.dart" as p;

import "package:polder/services/update/installer/update_installer.dart";

class MacosUpdateInstaller implements UpdateInstaller {
  const MacosUpdateInstaller();

  static const _swapScript = r'''
pid="$1"; staged="$2"; target="$3"; relaunch="$4"
while kill -0 "$pid" 2>/dev/null; do sleep 0.5; done
backup="$target.polder-old"
rm -rf "$backup"
mv "$target" "$backup" || exit 1
if mv "$staged" "$target"; then
  rm -rf "$backup"
else
  mv "$backup" "$target"
fi
if [ "$relaunch" = 1 ]; then open "$target"; fi
''';

  Directory get _bundle => File(Platform.resolvedExecutable).parent.parent.parent;

  @override
  Future<bool> canInstallInPlace() async {
    final bundle = _bundle;
    if (p.extension(bundle.path) != ".app" || bundle.path.contains("/AppTranslocation/")) return false;
    return isWritableDirectory(bundle.parent);
  }

  @override
  Future<void> install(File archive, {required bool relaunch}) async {
    final staging = Directory(p.join(archive.parent.path, "staged"));
    if (await staging.exists()) await staging.delete(recursive: true);
    await runChecked("/usr/bin/ditto", ["-x", "-k", archive.path, staging.path]);
    final app = await staging.list().firstWhere((entry) => p.extension(entry.path) == ".app");
    await Process.run("/usr/bin/xattr", ["-dr", "com.apple.quarantine", app.path]);
    await Process.start("/bin/sh", [
      "-c",
      _swapScript,
      "polder-update",
      "$pid",
      app.path,
      _bundle.path,
      relaunch ? "1" : "0",
    ], mode: ProcessStartMode.detached);
  }
}
