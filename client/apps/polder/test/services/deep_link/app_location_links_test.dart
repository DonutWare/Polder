import "package:flutter_test/flutter_test.dart";

import "package:polder/services/deep_link/app_location_link.dart";
import "package:polder_account_link/app_location_links.dart";
import "package:polder_account_link/companion_app.dart";

void main() {
  const location = "/files?path=%2FRecipes&select=soup.md";

  test("a link to the Drive app carries its location", () {
    final uri = AppLocationLinks.uriFor(CompanionApp.drive, location, dev: false);

    expect(uri.scheme, "polder-drive");
    expect(AppLocationLinks.locationOf(uri, CompanionApp.drive, dev: false), location);
    expect(AppLocationLinks.locationOf(uri, CompanionApp.drive, dev: true), isNull);
  });

  test("links to the main app are the ones Polder already understands", () {
    final uri = AppLocationLinks.uriFor(null, location, dev: false);

    expect(AppLocationLink.locationOf(uri), location);
  });

  test("only local locations are accepted", () {
    Uri link(String path) => Uri(scheme: "polder-drive", host: "open", queryParameters: {"path": path});

    expect(AppLocationLinks.locationOf(link("//evil.example.com"), CompanionApp.drive, dev: false), isNull);
    expect(AppLocationLinks.locationOf(link("https://evil.example.com"), CompanionApp.drive, dev: false), isNull);
  });
}
