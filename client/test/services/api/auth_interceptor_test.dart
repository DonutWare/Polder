import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/token_pair.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/auth_session.dart";
import "package:polder/services/api/polder_api.dart";

import "../../support/scripted_client.dart";

class FakeSession implements AuthSession {
  FakeSession({this.accessToken, this.refreshToken});

  @override
  String? accessToken;
  String? refreshToken;
  int stored = 0;
  bool expired = false;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> storeTokens(TokenPair tokens) async {
    stored++;
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }

  @override
  Future<void> expire() async => expired = true;
}

void main() {
  const validToken = "access-2";

  late FakeSession session;
  late int refreshCalls;
  late bool refreshSucceeds;
  late ScriptedClient client;
  late PolderApi api;

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    if (request.path.endsWith("/auth/refresh")) {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (!refreshSucceeds) {
        return jsonResponse(401, {
          "error": {"code": "unauthorized", "message": "revoked"},
        });
      }
      expect(request.data, {"refreshToken": "refresh-1"});
      expect(request.headers["Authorization"], isNull);
      return jsonResponse(200, tokenJson(validToken, "refresh-2"));
    }
    if (request.headers["Authorization"] != "Bearer $validToken") {
      return jsonResponse(401, {
        "error": {"code": "unauthorized", "message": "expired"},
      });
    }
    return jsonResponse(200, userJson());
  }

  setUp(() {
    session = FakeSession(accessToken: "access-1", refreshToken: "refresh-1");
    refreshCalls = 0;
    refreshSucceeds = true;
    client = ScriptedClient(handle);
    api = PolderApi(ApiClientFactory.create("https://cloud.test", session: session, httpClient: client));
  });

  test("sends the bearer token", () async {
    session.accessToken = validToken;

    await api.me();

    expect(client.requests.single.headers["Authorization"], "Bearer $validToken");
    expect(refreshCalls, 0);
  });

  test("refreshes on 401, stores the rotated pair and retries", () async {
    final user = await api.me();

    expect(user.username, "jop");
    expect(refreshCalls, 1);
    expect(session.stored, 1);
    expect(session.refreshToken, "refresh-2");
    expect(client.requests.last.headers["Authorization"], "Bearer $validToken");
  });

  test("concurrent 401s share a single in-flight refresh", () async {
    final users = await Future.wait([api.me(), api.me(), api.me(), api.me()]);

    expect(users, hasLength(4));
    expect(refreshCalls, 1);
    expect(session.stored, 1);
  });

  test("a rejected refresh expires the session and surfaces unauthorized", () async {
    refreshSucceeds = false;

    await expectLater(api.me(), throwsA(isA<UnauthorizedException>()));

    expect(session.expired, isTrue);
    expect(refreshCalls, 1);
  });

  test("anonymous endpoints never trigger a refresh", () async {
    await expectLater(
      api.login(username: "jop", password: "wrong", deviceName: "test"),
      throwsA(isA<UnauthorizedException>()),
    );

    expect(refreshCalls, 0);
    expect(client.requests.single.headers["Authorization"], isNull);
  });
}
