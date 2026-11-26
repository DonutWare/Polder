import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder_core/models/login_state.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/login_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late List<String> paths;
  late bool serverReachable;

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    paths.add(request.path);
    if (!serverReachable) throw http.ClientException("connection refused");
    return switch (request.path) {
      "/auth/refresh" => jsonResponse(401, {
        "error": {"code": "unauthorized", "message": "refresh token is invalid or expired"},
      }),
      "/auth/login" when (request.data! as Map)["password"] == "secret" => jsonResponse(
        200,
        tokenJson("fresh-access", "fresh-refresh"),
      ),
      "/auth/login" => jsonResponse(401, {
        "error": {"code": "unauthorized", "message": "nope"},
      }),
      "/auth/logout" => emptyResponse(204),
      _ => jsonResponse(401, {
        "error": {"code": "unauthorized", "message": "expired"},
      }),
    };
  }

  setUp(() async {
    paths = [];
    serverReachable = true;
    harness = ProviderHarness(httpClient: ScriptedClient(handle), account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  Future<void> endSessionThroughRefresh() async {
    await expectLater(harness.container.read(polderApiProvider).me(), throwsA(isA<UnauthorizedException>()));
  }

  LoginNotifier login() {
    final subscription = harness.container.listen(loginProvider, (_, _) {});
    addTearDown(subscription.close);
    return harness.container.read(loginProvider.notifier);
  }

  LoginState loginState() => harness.container.read(loginProvider);

  test("a rejected refresh keeps the account and marks its session ended", () async {
    await endSessionThroughRefresh();

    final account = harness.container.read(currentAccountProvider);
    expect(account?.user.username, "alice");
    expect(harness.container.read(sessionEndedProvider), isTrue);
    expect((await harness.credentials.load())?.sessionEnded, isTrue);
  });

  test("an ended session stops trying to refresh", () async {
    await endSessionThroughRefresh();
    paths.clear();

    await expectLater(harness.container.read(polderApiProvider).me(), throwsA(isA<UnauthorizedException>()));

    expect(paths, isNot(contains("/auth/refresh")));
  });

  test("the login screen asks only for the password of the ended account", () async {
    await endSessionThroughRefresh();
    login();

    expect(loginState().reauthenticating, isTrue);
    expect(loginState().step, LoginStep.credentials);
    expect(loginState().serverUrl, "https://cloud.test");
    expect(loginState().serverLocked, isTrue);
    expect(loginState().username, "alice");
  });

  test("signing in again resumes the same account with fresh tokens", () async {
    await endSessionThroughRefresh();
    final notifier = login()..setPassword("secret");

    await notifier.signIn();

    final account = harness.container.read(currentAccountProvider);
    expect(account?.sessionEnded, isFalse);
    expect(account?.accessToken, "fresh-access");
    expect((await harness.credentials.load())?.refreshToken, "fresh-refresh");
  });

  test("a wrong password keeps the session ended and says so", () async {
    await endSessionThroughRefresh();
    final notifier = login()..setPassword("wrong");

    await notifier.signIn();

    expect(loginState().failure, LoginFailure.invalidCredentials);
    expect(harness.container.read(sessionEndedProvider), isTrue);
  });

  test("signing out from an ended session removes the account without contacting the server", () async {
    await endSessionThroughRefresh();
    login();
    serverReachable = false;
    paths.clear();

    await harness.container.read(accountProvider.notifier).signOut();

    expect(harness.container.read(currentAccountProvider), isNull);
    expect(await harness.credentials.load(), isNull);
    expect(paths, isEmpty);
    expect(loginState().reauthenticating, isFalse);
    expect(loginState().serverLocked, isFalse);
  });

  test("continuing offline lasts until the user asks to sign in, and resets when the session ends again", () async {
    final subscription = harness.container.listen(continueOfflineProvider, (_, _) {});
    addTearDown(subscription.close);
    ContinueOfflineNotifier offline() => harness.container.read(continueOfflineProvider.notifier);
    offline().continueOffline();
    expect(harness.container.read(continueOfflineProvider), isFalse);

    await endSessionThroughRefresh();
    expect(harness.container.read(continueOfflineProvider), isFalse);
    offline().continueOffline();
    expect(harness.container.read(continueOfflineProvider), isTrue);

    offline().signInAgain();
    expect(harness.container.read(continueOfflineProvider), isFalse);
  });

  test("signing out while the server is unreachable still removes the account", () async {
    serverReachable = false;

    await harness.container.read(accountProvider.notifier).signOut();

    expect(harness.container.read(currentAccountProvider), isNull);
    expect(await harness.credentials.load(), isNull);
  });
}
