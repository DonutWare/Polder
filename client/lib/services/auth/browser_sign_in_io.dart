import "dart:async";
import "dart:io";

import "package:url_launcher/url_launcher.dart";

class BrowserSignInCancelled implements Exception {
  const BrowserSignInCancelled();
}

class BrowserSignIn {
  static const _timeout = Duration(minutes: 10);

  static Completer<Uri>? _pending;

  static Future<Uri> run({
    required Future<Uri> Function(String redirectUri) start,
    required String finishedPage,
    Future<bool> Function(Uri url) open = _openInBrowser,
  }) async {
    cancel();
    final pending = Completer<Uri>();
    pending.future.ignore();
    _pending = pending;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    try {
      server.listen((request) => _answer(request, pending, finishedPage));
      final url = await start("http://${InternetAddress.loopbackIPv4.address}:${server.port}/");
      if (!pending.isCompleted && !await open(url)) throw StateError("No browser opened $url");
      return await pending.future.timeout(_timeout, onTimeout: () => throw const BrowserSignInCancelled());
    } finally {
      if (identical(_pending, pending)) _pending = null;
      await server.close(force: true);
    }
  }

  static Future<bool> _openInBrowser(Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);

  static void cancel() {
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) pending.completeError(const BrowserSignInCancelled());
  }

  static Future<void> _answer(HttpRequest request, Completer<Uri> pending, String finishedPage) async {
    final response = request.response;
    if (request.method != "GET" || request.uri.path != "/" || request.uri.queryParameters.isEmpty) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    response.headers.contentType = ContentType.html;
    response.headers.set(HttpHeaders.cacheControlHeader, "no-store");
    response.write(finishedPage);
    await response.close();
    if (!pending.isCompleted) pending.complete(request.uri);
  }
}
