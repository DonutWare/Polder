import "dart:async";
import "dart:convert";
import "dart:math";

import "package:crypto/crypto.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_web_auth_2/flutter_web_auth_2.dart";

import "package:polder_core/services/auth/browser_sign_in.dart";
import "package:polder_core/l10n/device_core_localizations.dart";

enum SingleSignOnFailure { signupDisabled, accountDisabled, alreadyLinked, linkRequired, cancelled, failed }

class SingleSignOnException implements Exception {
  const SingleSignOnException(this.failure);

  final SingleSignOnFailure failure;

  static SingleSignOnException fromCode(String code) => SingleSignOnException(switch (code) {
    "signup_disabled" => SingleSignOnFailure.signupDisabled,
    "account_disabled" => SingleSignOnFailure.accountDisabled,
    "already_linked" => SingleSignOnFailure.alreadyLinked,
    "link_required" => SingleSignOnFailure.linkRequired,
    "cancelled" => SingleSignOnFailure.cancelled,
    _ => SingleSignOnFailure.failed,
  });
}

class SingleSignOnResult {
  const SingleSignOnResult({required this.code, required this.verifier});

  final String code;
  final String verifier;
}

class SingleSignOnConfig {
  const SingleSignOnConfig({required this.appName, required this.callbackScheme, this.onBrowserReturn});

  final String appName;
  final String callbackScheme;
  final Future<void> Function()? onBrowserReturn;
}

abstract final class SingleSignOn {
  static late SingleSignOnConfig config;

  static String get _scheme => config.callbackScheme;

  static bool get finishesInBrowser =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
        _ => false,
      };

  static String get _sheetRedirectUri => kIsWeb ? "${Uri.base.origin}/auth.html" : "$_scheme://auth";

  static Future<SingleSignOnResult> signIn({
    required String serverUrl,
    required String providerId,
    required String deviceName,
  }) async {
    final verifier = _randomVerifier();
    return _withCode(
      verifier,
      (redirectUri) async => Uri.parse("$serverUrl/api/v1/auth/sso/${Uri.encodeComponent(providerId)}/authorize")
          .replace(
            queryParameters: {
              "redirect_uri": redirectUri,
              "code_challenge": _challengeOf(verifier),
              "device_name": deviceName,
            },
          ),
    );
  }

  static Future<SingleSignOnResult> link(
    Future<String> Function({required String redirectUri, required String codeChallenge}) start,
  ) {
    final verifier = _randomVerifier();
    return _withCode(
      verifier,
      (redirectUri) async => Uri.parse(await start(redirectUri: redirectUri, codeChallenge: _challengeOf(verifier))),
    );
  }

  static Future<SingleSignOnResult> _withCode(String verifier, Future<Uri> Function(String redirectUri) start) async {
    final result = await _authenticate(start);
    final code = result.queryParameters["code"];
    if (code == null) throw SingleSignOnException.fromCode(result.queryParameters["error"] ?? "");
    return SingleSignOnResult(code: code, verifier: verifier);
  }

  static void cancel() => BrowserSignIn.cancel();

  static Future<Uri> _authenticate(Future<Uri> Function(String redirectUri) start) async {
    try {
      if (finishesInBrowser) {
        final result = await BrowserSignIn.run(start: start, finishedPage: _finishedPage());
        final onBrowserReturn = config.onBrowserReturn;
        if (onBrowserReturn != null) unawaited(onBrowserReturn());
        return result;
      }
      final url = await start(_sheetRedirectUri);
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: _scheme,
        options: const FlutterWebAuth2Options(useWebview: false),
      );
      return Uri.parse(result);
    } on BrowserSignInCancelled {
      throw const SingleSignOnException(SingleSignOnFailure.cancelled);
    } on PlatformException catch (error) {
      if (error.code == "CANCELED") throw const SingleSignOnException(SingleSignOnFailure.cancelled);
      rethrow;
    }
  }

  static String _finishedPage() {
    final localized = deviceCoreLocalizations();
    const escape = HtmlEscape();
    final title = escape.convert(localized.browserSignInFinishedTitle(config.appName));
    final message = escape.convert(localized.browserSignInFinished(config.appName));
    return """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>$title</title>
<style>:root{color-scheme:light dark}body{font:16px system-ui,sans-serif;display:grid;place-items:center;min-height:100vh;margin:0;padding:0 16px}main{max-width:28rem;text-align:center}h1{font-size:1.4rem}</style>
</head><body><main><h1>$title</h1><p>$message</p></main></body></html>""";
  }

  static String _randomVerifier() {
    final random = Random.secure();
    return base64UrlEncode([for (var i = 0; i < 32; i++) random.nextInt(256)]).replaceAll("=", "");
  }

  static String _challengeOf(String verifier) =>
      base64UrlEncode(sha256.convert(utf8.encode(verifier)).bytes).replaceAll("=", "");
}
