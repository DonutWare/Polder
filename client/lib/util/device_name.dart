import "package:flutter/foundation.dart";

abstract final class DeviceName {
  static String current() {
    if (kIsWeb) return "Web";
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => "Android",
      TargetPlatform.iOS => "iOS",
      TargetPlatform.macOS => "macOS",
      TargetPlatform.windows => "Windows",
      TargetPlatform.linux => "Linux",
      TargetPlatform.fuchsia => "Fuchsia",
    };
  }
}
