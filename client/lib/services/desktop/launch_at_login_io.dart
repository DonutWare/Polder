import "dart:io";

import "package:flutter/services.dart";

import "package:path/path.dart" as p;
import "package:win32_registry/win32_registry.dart";

import "package:polder/services/desktop/launch_at_login_interface.dart";

export "package:polder/services/desktop/launch_at_login_interface.dart";

LaunchAtLogin? createLaunchAtLogin() {
  if (Platform.isMacOS) return const MacosLaunchAtLogin();
  if (Platform.isWindows) return const WindowsLaunchAtLogin();
  if (Platform.isLinux) return LinuxLaunchAtLogin(Platform.environment);
  return null;
}

class MacosLaunchAtLogin implements LaunchAtLogin {
  const MacosLaunchAtLogin();

  static const _channel = MethodChannel("polder/launchAtLogin");

  @override
  Future<bool?> isEnabled() => _channel.invokeMethod<bool>("enabled");

  @override
  Future<void> setEnabled(bool enabled) => _channel.invokeMethod<void>("setEnabled", enabled);

  @override
  Future<bool> launchedAtLogin(List<String> arguments) async =>
      await _channel.invokeMethod<bool>("launchedAtLogin") ?? false;
}

class WindowsLaunchAtLogin implements LaunchAtLogin {
  const WindowsLaunchAtLogin();

  static const _runKey = r"Software\Microsoft\Windows\CurrentVersion\Run";
  static const _valueName = "Polder";

  String get _command => '"${Platform.resolvedExecutable}" $launchedAtLoginArgument';

  @override
  Future<bool?> isEnabled() async {
    final key = CURRENT_USER.create(_runKey);
    try {
      return key.getString(_valueName) == _command;
    } finally {
      key.close();
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final key = CURRENT_USER.create(_runKey, config: const .new(access: .readWrite, create: true));
    try {
      if (enabled) {
        key.setValue(_valueName, RegistryValue.string(_command));
      } else if (key.getString(_valueName) != null) {
        key.removeValue(_valueName);
      }
    } finally {
      key.close();
    }
  }

  @override
  Future<bool> launchedAtLogin(List<String> arguments) async => arguments.contains(launchedAtLoginArgument);
}

class LinuxLaunchAtLogin implements LaunchAtLogin {
  const LinuxLaunchAtLogin(this._environment);

  static const _applicationId = "org.knaapen.polder";

  final Map<String, String> _environment;

  String? get _flatpakId => _environment["FLATPAK_ID"];

  File get _entry {
    final home = _environment["HOME"] ?? "";
    final configHome = _flatpakId == null ? _environment["XDG_CONFIG_HOME"] : null;
    final directory = configHome == null || configHome.isEmpty ? p.join(home, ".config") : configHome;
    return File(p.join(directory, "autostart", "${_flatpakId ?? _applicationId}.desktop"));
  }

  String get _command {
    final flatpakId = _flatpakId;
    final executable = flatpakId == null
        ? '"${_environment["APPIMAGE"] ?? Platform.resolvedExecutable}"'
        : "flatpak run $flatpakId";
    return "$executable $launchedAtLoginArgument";
  }

  @override
  Future<bool?> isEnabled() => _entry.exists();

  @override
  Future<void> setEnabled(bool enabled) async {
    final entry = _entry;
    if (!enabled) {
      if (await entry.exists()) await entry.delete();
      return;
    }
    await entry.parent.create(recursive: true);
    await entry.writeAsString(
      [
        "[Desktop Entry]",
        "Type=Application",
        "Name=Polder",
        "Exec=$_command",
        "Icon=${_flatpakId ?? "polder_icon_desktop"}",
        "Terminal=false",
        "X-GNOME-Autostart-enabled=true",
        "",
      ].join("\n"),
    );
  }

  @override
  Future<bool> launchedAtLogin(List<String> arguments) async => arguments.contains(launchedAtLoginArgument);
}
