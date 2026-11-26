import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder_core/models/login_state.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/login_provider.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late bool needsSetup;
  late Map<String, dynamic> approvalStatus;
  late ProviderHarness harness;

  Future<http.StreamedResponse> handle(RecordedRequest request) async => switch (request.path) {
    "/setup" when request.method == "GET" => jsonResponse(200, {"needsSetup": needsSetup}),
    "/setup" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/login" when (request.data as Map)["password"] == "secret" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/login" when (request.data as Map)["password"] == "two-factor" => jsonResponse(401, {
      "error": {"code": "two_factor_required", "message": "code needed"},
      "current": {"challenge": "c1", "expiresIn": 300, "deviceApproval": true},
    }),
    "/auth/two-factor" when (request.data as Map)["code"] == "123456" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/two-factor" => jsonResponse(401, {
      "error": {"code": "unauthorized", "message": "wrong"},
    }),
    "/auth/device-login" => jsonResponse(201, {"requestId": "q1", "pollToken": "p1", "number": 42, "expiresIn": 120}),
    "/auth/device-login/q1/status" => jsonResponse(200, approvalStatus),
    "/auth/login" => jsonResponse(401, {
      "error": {"code": "unauthorized", "message": "nope"},
    }),
    _ => jsonResponse(404, {
      "error": {"code": "not_found", "message": ""},
    }),
  };

  setUp(() {
    needsSetup = false;
    approvalStatus = {"status": "pending"};
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
      ..setUsername("alice")
      ..setPassword("secret");

    await notifier.signIn();

    final account = await harness.container.read(accountProvider.future);
    expect(account?.user.username, "alice");
    expect(account?.refreshToken, "r");
    expect((await harness.credentials.load())?.refreshToken, "r");
    expect(state().completed, isTrue);
  });

  test("wrong credentials report a typed failure", () async {
    final notifier = await connected("https://cloud.test");
    notifier
      ..setUsername("alice")
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

  test("a second factor is asked for when the account has one", () async {
    final notifier = await connected("https://cloud.test");
    notifier
      ..setUsername("alice")
      ..setPassword("two-factor");

    await notifier.signIn();

    expect(state().step, LoginStep.twoFactor);
    expect(state().challenge, "c1");
    expect(state().deviceApprovalAvailable, isTrue);

    notifier.setCode("000000");
    await notifier.verifyTwoFactor();
    expect(state().failure, LoginFailure.invalidCode);

    notifier.setCode("123456");
    await notifier.verifyTwoFactor();
    expect(state().completed, isTrue);
  });

  test("another device can approve a passwordless sign in", () async {
    final notifier = await connected("https://cloud.test");
    notifier.setUsername("alice");

    await notifier.askAnotherDevice();
    expect(state().step, LoginStep.deviceApproval);
    expect(state().deviceLogin?.number, 42);

    approvalStatus = {"status": "approved", "tokens": tokenJson("a", "r")};
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    expect(state().completed, isTrue);
  });

  test("a refused approval returns to the credentials", () async {
    final notifier = await connected("https://cloud.test");
    notifier.setUsername("alice");
    await notifier.askAnotherDevice();

    approvalStatus = {"status": "denied"};
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    expect(state().step, LoginStep.credentials);
    expect(state().failure, LoginFailure.approvalDenied);
  });
}
