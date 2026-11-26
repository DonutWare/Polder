import "dart:io";

import "package:path/path.dart" as p;

abstract interface class UpdateInstaller {
  Future<bool> canInstallInPlace();

  Future<void> install(File archive, {required bool relaunch});
}

Future<bool> isWritableDirectory(Directory directory) async {
  final probe = File(p.join(directory.path, ".polder-update-${DateTime.now().microsecondsSinceEpoch}"));
  try {
    await probe.writeAsString("");
    await probe.delete();
    return true;
  } on FileSystemException {
    return false;
  }
}

Future<void> runChecked(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(executable, arguments, "${result.stderr}".trim(), result.exitCode);
  }
}
