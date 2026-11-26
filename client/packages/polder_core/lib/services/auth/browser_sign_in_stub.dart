class BrowserSignIn {
  static Future<Uri> run({required Future<Uri> Function(String redirectUri) start, required String finishedPage}) =>
      throw UnsupportedError("Signing in through the browser needs a desktop app");

  static void cancel() {}
}

class BrowserSignInCancelled implements Exception {
  const BrowserSignInCancelled();
}
