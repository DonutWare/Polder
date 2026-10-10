import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/desktop/finder_location_provider.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ScriptedClient server;

  setUp(() {
    var sessions = 0;
    server = ScriptedClient((request) async {
      if (request.path != "/auth/sessions") return emptyResponse(204);
      return jsonResponse(201, tokenJson("finder-access", "finder-${++sessions}"));
    });
  });

  Iterable<String> revoked() => [
    for (final request in server.requests)
      if (request.path == "/auth/logout") (request.data! as Map)["refreshToken"] as String,
  ];

  Future<ProviderHarness> started({required bool signedIn, PreferencesStore? preferences}) async {
    final harness = ProviderHarness(
      httpClient: server,
      account: signedIn ? testAccount() : null,
      preferences: preferences,
    );
    addTearDown(harness.dispose);
    harness.container.read(showInFinderProvider);
    await pumpEventQueue();
    return harness;
  }

  test("signs the Finder location in with a session of its own", () async {
    final harness = await started(signedIn: true);

    expect(harness.finderLocation.accountId, testAccount().id);
    expect(harness.finderLocation.session?.refreshToken, "finder-1");
    final request = server.requests.singleWhere((request) => request.path == "/auth/sessions");
    expect(request.data, {"deviceName": "Test (Finder)"});
  });

  test("keeps the session of an account that is already connected", () async {
    final harness = ProviderHarness(httpClient: server, account: testAccount());
    addTearDown(harness.dispose);
    harness.finderLocation
      ..accountId = testAccount().id
      ..session = (serverUrl: testAccount().serverUrl, refreshToken: "earlier");

    harness.container.read(showInFinderProvider);
    await pumpEventQueue();

    expect(server.requests.where((request) => request.path == "/auth/sessions"), isEmpty);
    expect(harness.finderLocation.session?.refreshToken, "earlier");
    expect(harness.finderLocation.signals, 1);
  });

  test("revokes the session of the account it replaces", () async {
    final harness = ProviderHarness(httpClient: server, account: testAccount());
    addTearDown(harness.dispose);
    harness.finderLocation
      ..accountId = "bob@https://cloud.test"
      ..session = (serverUrl: "https://cloud.test", refreshToken: "bobs");

    harness.container.read(showInFinderProvider);
    await pumpEventQueue();

    expect(harness.finderLocation.accountId, testAccount().id);
    expect(revoked(), ["bobs"]);
  });

  test("signing out removes the location and revokes its session", () async {
    final harness = await started(signedIn: true);

    await harness.container.read(accountProvider.notifier).signOut();
    await pumpEventQueue();

    expect(harness.finderLocation.accountId, isNull);
    expect(revoked(), containsAll(["refresh", "finder-1"]));
  });

  test("leaves Finder alone while signed out", () async {
    final harness = await started(signedIn: false);

    expect(harness.finderLocation.accountId, isNull);
    expect(server.requests, isEmpty);
  });

  test("turning it off removes the location and revokes its session", () async {
    final harness = await started(signedIn: true);

    await harness.container.read(showInFinderProvider.notifier).setShown(false);

    expect(harness.finderLocation.accountId, isNull);
    expect(revoked(), ["finder-1"]);
    expect(harness.container.read(showInFinderProvider).value, isFalse);
  });

  test("stays out of Finder after a restart once turned off", () async {
    final preferences = InMemoryPreferencesStore();
    final first = await started(signedIn: true, preferences: preferences);
    await first.container.read(showInFinderProvider.notifier).setShown(false);

    final second = await started(signedIn: true, preferences: preferences);

    expect(second.container.read(showInFinderProvider).value, isFalse);
    expect(second.finderLocation.accountId, isNull);
    expect(server.requests.where((request) => request.path == "/auth/sessions"), hasLength(1));
  });

  test("turning it back on connects again", () async {
    final harness = await started(signedIn: true);
    final notifier = harness.container.read(showInFinderProvider.notifier);

    await notifier.setShown(false);
    await notifier.setShown(true);

    expect(harness.finderLocation.accountId, testAccount().id);
    expect(harness.finderLocation.session?.refreshToken, "finder-2");
  });
}
