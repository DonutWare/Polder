import "dart:async";

import "package:chopper/chopper.dart";

import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/auth_session.dart";
import "package:polder/services/api/generated/polder.metadata.swagger.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/pending_uploads.dart";
import "package:polder/services/api/wire_mappers.dart";

class AuthInterceptor extends Authenticator implements Interceptor {
  AuthInterceptor({required this._session, required this._refreshApi});

  final AuthSession _session;
  final wire.Polder _refreshApi;
  final _inFlight = _InFlightRefresh();

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    final token = _session.accessToken;
    if (!_isSecured(chain.request) || token == null) return chain.proceed(chain.request);
    return chain.proceed(_withToken(chain.request, token));
  }

  @override
  Future<Request?> authenticate(Request request, Response<dynamic> response, [Request? originalRequest]) async {
    if (response.statusCode != 401 || !_isSecured(request)) return null;
    final token = await _refreshedAccessToken(request);
    if (token == null || PendingUploads.isUpload(request)) return null;
    return _withToken(request, token);
  }

  static bool _isSecured(Request request) => switch (request.tag) {
    final SwaggerMetaData operation => operation.security.isNotEmpty,
    _ => false,
  };

  static Request _withToken(Request request, String token) => applyHeader(request, "Authorization", "Bearer $token");

  Future<String?> _refreshedAccessToken(Request failedRequest) {
    final currentToken = _session.accessToken;
    if (currentToken != null && failedRequest.headers["Authorization"] != "Bearer $currentToken") {
      return Future.value(currentToken);
    }
    return _inFlight.refresh ??= _refresh().whenComplete(() => _inFlight.refresh = null);
  }

  Future<String?> _refresh() async {
    final refreshToken = await _session.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _refreshApi.refresh(body: wire.RefreshRequest(refreshToken: refreshToken));
      final tokens = response.body!.toModel();
      await _session.storeTokens(tokens);
      return tokens.accessToken;
    } on ApiException catch (error) {
      if (const {400, 401, 403}.contains(error.statusCode)) await _session.expire();
      return null;
    }
  }
}

class _InFlightRefresh {
  Future<String?>? refresh;
}
