import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:url_launcher/url_launcher.dart";

import "package:polder_account_link/companion_app.dart";

abstract final class AppLocationLinks {
  static const host = "open";
  static const pathParameter = "path";

  static String schemeOf(CompanionApp? app, {required bool dev}) =>
      app == null ? (dev ? "polder-dev" : "polder") : "polder-${app.id}${dev ? "-dev" : ""}";

  static Uri uriFor(CompanionApp? app, String location, {required bool dev}) => Uri(
    scheme: schemeOf(app, dev: dev),
    host: host,
    queryParameters: {pathParameter: location},
  );

  static String? locationOf(Uri uri, CompanionApp? app, {required bool dev}) {
    if (uri.scheme != schemeOf(app, dev: dev) || uri.host != host) return null;
    final location = uri.queryParameters[pathParameter];
    if (location == null || !location.startsWith("/") || location.startsWith("//")) return null;
    return location;
  }

  static Future<bool> openInFirstOf(List<CompanionApp?> apps, String location, {required bool dev}) async {
    for (final app in apps) {
      if (await _launch(uriFor(app, location, dev: dev))) return true;
    }
    return false;
  }

  static LaunchMode get _mode =>
      defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS
      ? LaunchMode.externalNonBrowserApplication
      : LaunchMode.externalApplication;

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: _mode);
    } on PlatformException {
      return false;
    }
  }
}
