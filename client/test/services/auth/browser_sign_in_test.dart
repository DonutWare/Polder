import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:polder/services/auth/browser_sign_in_io.dart";

Future<(int, String)> visit(Uri url) async {
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(url)).close();
    return (response.statusCode, await response.transform(const SystemEncoding().decoder).join());
  } finally {
    client.close();
  }
}

void main() {
  test("the browser's redirect back finishes the sign-in and shows the finished page", () async {
    late String redirect;
    String? page;
    final result = await BrowserSignIn.run(
      start: (redirectUri) async {
        redirect = redirectUri;
        return Uri.parse("https://idp.example/authorize");
      },
      finishedPage: "<p>done</p>",
      open: (url) async {
        unawaited(() async {
          final (missing, _) = await visit(Uri.parse("${redirect}favicon.ico"));
          expect(missing, HttpStatus.notFound);
          final (status, body) = await visit(Uri.parse("$redirect?code=abc"));
          expect(status, HttpStatus.ok);
          page = body;
        }());
        return true;
      },
    );
    expect(redirect, startsWith("http://127.0.0.1:"));
    expect(result.queryParameters["code"], "abc");
    await pumpEventQueue();
    expect(page, "<p>done</p>");
  });

  test("cancelling stops waiting for the browser", () async {
    final waiting = BrowserSignIn.run(
      start: (redirectUri) async => Uri.parse("https://idp.example/authorize"),
      finishedPage: "",
      open: (url) async {
        Timer.run(BrowserSignIn.cancel);
        return true;
      },
    );
    await expectLater(waiting, throwsA(isA<BrowserSignInCancelled>()));
  });
}
