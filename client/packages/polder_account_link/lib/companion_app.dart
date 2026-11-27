import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

enum CompanionApp {
  drive("drive"),
  notes("notes"),
  calendar("calendar");

  const CompanionApp(this.id);

  final String id;

  String androidPackage({required bool dev}) => "org.knaapen.polder.$id${dev ? ".dev" : ""}";

  String launchScheme({required bool dev}) => "polder-$id${dev ? "-dev" : ""}-open";
}

abstract final class CompanionApps {
  static const _methods = MethodChannel("polder/account_link");

  static bool get canDetect =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  static Future<bool> isInstalled(CompanionApp app, {required bool dev}) async {
    if (!canDetect) return false;
    try {
      return await _methods.invokeMethod<bool>("isInstalled", _target(app, dev: dev)) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> open(CompanionApp app, {required bool dev}) async {
    if (!canDetect) return false;
    try {
      return await _methods.invokeMethod<bool>("open", _target(app, dev: dev)) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Map<String, String> _target(CompanionApp app, {required bool dev}) => {
    "package": app.androidPackage(dev: dev),
    "scheme": app.launchScheme(dev: dev),
  };
}
