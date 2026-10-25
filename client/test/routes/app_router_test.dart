import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:polder/routes/app_router.dart";

import "../support/provider_harness.dart";

void main() {
  test("every route builds its own page, so none silently loses its transitions", () {
    final harness = ProviderHarness();
    addTearDown(harness.dispose);
    final router = harness.container.read(routerProvider);

    Iterable<GoRoute> goRoutes(List<RouteBase> routes) sync* {
      for (final route in routes) {
        if (route is GoRoute) yield route;
        yield* goRoutes(route.routes);
      }
    }

    final withoutPage = [
      for (final route in goRoutes(router.configuration.routes))
        if (route.pageBuilder == null) route.path,
    ];
    expect(withoutPage, isEmpty);
  });
}
