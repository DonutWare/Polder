import "package:flutter_test/flutter_test.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/services/deep_link/share_link_target.dart";

void main() {
  test("app links name the server and the code", () {
    final target = ShareLinkTarget.parse(Uri.parse("polder://share?server=files.example.com&code=Ab3dE9xQ2k"))!;
    expect(target.serverUrl, "https://files.example.com");
    expect(target.code, "Ab3dE9xQ2k");
  });

  test("dev builds have their own scheme", () {
    final target = ShareLinkTarget.parse(Uri.parse("polder-dev://share?server=http://nas.local:8080&code=Ab3dE9xQ2k"));
    expect(target?.serverUrl, "http://nas.local:8080");
  });

  test("anything else is not a share link", () {
    for (final link in [
      "polder://share?code=Ab3dE9xQ2k",
      "polder://share?server=files.example.com&code=../etc",
      "polder://other?server=files.example.com&code=Ab3dE9xQ2k",
      "https://files.example.com/share/Ab3dE9xQ2k",
      "mailto:someone@example.com",
    ]) {
      expect(ShareLinkTarget.parse(Uri.parse(link)), isNull, reason: link);
    }
  });

  test("an app link round-trips", () {
    const target = ShareLinkTarget(serverUrl: "https://files.example.com", code: "Ab3dE9xQ2k");
    final parsed = ShareLinkTarget.parse(target.appUri)!;
    expect(parsed.serverUrl, target.serverUrl);
    expect(parsed.code, target.code);
  });

  test("links only match the account on the same server", () {
    const target = ShareLinkTarget(serverUrl: "https://files.example.com", code: "Ab3dE9xQ2k");
    expect(target.isOn("files.example.com"), isTrue);
    expect(target.isOn("https://other.example.com"), isFalse);
    expect(target.isOn(null), isFalse);
  });

  test("without an account the link opens the public page", () async {
    const target = ShareLinkTarget(serverUrl: "https://files.example.com", code: "Ab3dE9xQ2k");
    expect(await target.locationFor(null), AppRoutes.publicShareAt("Ab3dE9xQ2k", server: "https://files.example.com"));
  });
}
