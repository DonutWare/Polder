import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/services/device/windows_wallpaper_stub.dart"
    if (dart.library.ffi) "package:polder/services/device/windows_wallpaper.dart";

abstract final class Wallpaper {
  static const _channel = MethodChannel("polder/wallpaper");
  static const _folder = "wallpaper";
  static const _formats = {"image/jpeg", "image/png", "image/webp", "image/bmp", "image/heic", "image/heif"};

  static TargetPlatform? get _platform => kIsWeb ? null : defaultTargetPlatform;

  static bool canUse(FileEntry entry) =>
      _formats.contains(entry.mime) &&
      switch (_platform) {
        TargetPlatform.android || TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
        _ => false,
      };

  static bool get opensChooser => _platform == TargetPlatform.android;

  static Future<void> set(Uint8List bytes, {required String name, required String chooserTitle}) async {
    final file = await _store(bytes, name);
    switch (_platform) {
      case TargetPlatform.android:
        await _channel.invokeMethod<void>("set", {"path": file.path, "title": chooserTitle});
      case TargetPlatform.macOS:
        await _channel.invokeMethod<void>("set", {"path": file.path});
      case TargetPlatform.windows:
        setWindowsWallpaper(file.path);
      case TargetPlatform.linux:
        await _setOnLinux(file.path);
      default:
        throw UnsupportedError("Setting a wallpaper is not supported here");
    }
  }

  static Future<File> _store(Uint8List bytes, String name) async {
    final base = _platform == TargetPlatform.android
        ? await getTemporaryDirectory()
        : await getApplicationSupportDirectory();
    final directory = Directory(p.join(base.path, _folder));
    if (directory.existsSync()) await directory.delete(recursive: true);
    final file = await File(p.join(directory.path, "${DateTime.now().millisecondsSinceEpoch}-$name"))
        .create(recursive: true);
    return file.writeAsBytes(bytes);
  }

  static Future<void> _setOnLinux(String path) async {
    final uri = Uri.file(path).toString();
    final gnome = await Future.wait([
      for (final key in ["picture-uri", "picture-uri-dark"])
        _run("gsettings", ["set", "org.gnome.desktop.background", key, uri]),
    ]);
    if (gnome.every((succeeded) => succeeded)) return;
    if (await _run("plasma-apply-wallpaperimage", [path])) return;
    throw UnsupportedError("This desktop does not let apps change the wallpaper");
  }

  static Future<bool> _run(String executable, List<String> arguments) async {
    try {
      return (await Process.run(executable, arguments)).exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}
