import "package:flutter_test/flutter_test.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/services/deep_link/app_location_link.dart";

void main() {
  test("an open link round-trips an app location", () {
    final location = AppRoutes.sharedAt(12, path: "/Photos");
    expect(AppLocationLink.locationOf(AppLocationLink.uriFor(location)), location);
  });

  test("dev builds open locations with their own scheme", () {
    expect(AppLocationLink.locationOf(Uri.parse("polder-dev://open?path=/auto-upload")), "/auto-upload");
  });

  test("only in-app locations are opened", () {
    for (final link in [
      "polder://open",
      "polder://open?path=https://evil.example.com",
      "polder://open?path=//evil.example.com",
      "polder://open?path=/login",
      "polder://share?path=/files",
      "https://files.example.com/open?path=/files",
    ]) {
      expect(AppLocationLink.locationOf(Uri.parse(link)), isNull, reason: link);
    }
  });
}
