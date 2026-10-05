import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/login_state.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/login_provider.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late bool needsSetup;
  late ProviderHarness harness;

  Future<http.StreamedResponse> handle(RecordedRequest request) async => switch (request.path) {
    "/setup" when request.method == "GET" => jsonResponse(200, {"needsSetup": needsSetup}),
    "/setup" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/login" when (request.data as Map)["password"] == "secret" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/login" => jsonResponse(401, {
      "error": {"code": "unauthorized", "message": "nope"},
    }),
    _ => jsonResponse(404, {
      "error": {"code": "not_found", "message": ""},
    }),
  };

  setUp(() {
    needsSetup = false;
    harness = ProviderHarness(httpClient: ScriptedClient(handle));
  });

  tearDown(() => harness.dispose());

  Future<LoginNotifier> connected(String url) async {
    final subscription = harness.container.listen(loginProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = harness.container.read(loginProvider.notifier)..setServerUrl(url);
    await notifier.connect();
    return notifier;
  }

  LoginState state() => harness.container.read(loginProvider);

  test("connect normalizes the url and moves to credentials", () async {
    await connected("cloud.test/");

    expect(state().serverUrl, "https://cloud.test");
    expect(state().step, LoginStep.credentials);
  });

  test("connect moves to first-run setup when the server needs it", () async {
    needsSetup = true;

    await connected("https://cloud.test");

    expect(state().step, LoginStep.setup);
  });

  test("a successful sign in stores the account", () async {
    final notifier = await connected("https://cloud.test");
    notifier
      ..setUsername("jop")
      ..setPassword("secret");

    await notifier.signIn();

    final account = await harness.container.read(accountProvider.future);
    expect(account?.user.username, "jop");
    expect(account?.refreshToken, "r");
    expect((await harness.credentials.load())?.refreshToken, "r");
    expect(state().completed, isTrue);
  });

  test("wrong credentials report a typed failure", () async {
    final notifier = await connected("https://cloud.test");
    notifier
      ..setUsername("jop")
      ..setPassword("wrong");

    await notifier.signIn();

    expect(state().failure, LoginFailure.invalidCredentials);
    expect(state().loading, isFalse);
  });

  test("first-run setup signs in as the new admin", () async {
    needsSetup = true;
    final notifier = await connected("https://cloud.test");
    notifier
      ..setUsername("admin")
      ..setPassword("secret");

    await notifier.createAdmin();

    expect(harness.container.read(currentAccountProvider), isNotNull);
  });
}
