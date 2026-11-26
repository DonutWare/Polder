import "dart:io";

import "package:flutter/foundation.dart";

import "package:device_info_plus/device_info_plus.dart";

abstract final class DeviceName {
  static Future<String> resolve() async {
    try {
      final name = (await _deviceName()).trim();
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return _platform;
  }

  static Future<String> _deviceName() async {
    final info = DeviceInfoPlugin();
    if (kIsWeb) return "${_browser((await info.webBrowserInfo).browserName)} on $_platform";
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _android(await info.androidInfo),
      TargetPlatform.iOS => _ios(await info.iosInfo),
      TargetPlatform.macOS => (await info.macOsInfo).computerName,
      TargetPlatform.windows => (await info.windowsInfo).computerName,
      TargetPlatform.linux => Platform.localHostname,
      TargetPlatform.fuchsia => _platform,
    };
  }

  static String _android(AndroidDeviceInfo info) => info.name.isNotEmpty ? info.name : info.model;

  static String _ios(IosDeviceInfo info) => info.name == info.model ? info.modelName : info.name;

  static String _browser(BrowserName browser) => switch (browser) {
    BrowserName.firefox => "Firefox",
    BrowserName.samsungInternet => "Samsung Internet",
    BrowserName.opera => "Opera",
    BrowserName.msie => "Internet Explorer",
    BrowserName.edge => "Edge",
    BrowserName.chrome => "Chrome",
    BrowserName.safari => "Safari",
    BrowserName.unknown => "Browser",
  };

  static String get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => "Android",
    TargetPlatform.iOS => "iOS",
    TargetPlatform.macOS => "macOS",
    TargetPlatform.windows => "Windows",
    TargetPlatform.linux => "Linux",
    TargetPlatform.fuchsia => "Fuchsia",
  };
}
