import "package:http/http.dart" as http;

import "package:polder/services/api/api_error_mapper.dart";
import "package:polder/services/api/auth_interceptor.dart";
import "package:polder/services/api/auth_session.dart";
import "package:polder/services/api/generated/polder.swagger.dart";
import "package:polder/services/api/http_client.dart";
import "package:polder/services/api/polder_converter.dart";
import "package:polder/services/api/pending_uploads.dart";
import "package:polder/services/api/stall_guard_client.dart";

abstract final class ApiClientFactory {
  static Polder create(
    String serverUrl, {
    AuthSession? session,
    String? deviceName,
    http.Client? httpClient,
    ReachabilityListener? onReachability,
  }) {
    final uploads = PendingUploads();
    final client = UploadingClient(StallGuardClient(httpClient ?? createHttpClient()), uploads);
    final errors = ApiErrorInterceptor(onReachability: onReachability);
    final auth = session == null
        ? null
        : AuthInterceptor(
            session: session,
            deviceName: deviceName,
            refreshApi: _service(serverUrl, client, uploads, errors),
          );
    return _service(serverUrl, client, uploads, errors, auth);
  }

  static String normalizeServerUrl(String input) {
    final trimmed = input.trim().replaceAll(RegExp(r"/+$"), "");
    return trimmed.contains("://") ? trimmed : "https://$trimmed";
  }

  static Polder _service(
    String serverUrl,
    http.Client client,
    PendingUploads uploads,
    ApiErrorInterceptor errors, [
    AuthInterceptor? auth,
  ]) => Polder.create(
    baseUrl: Uri.parse(serverUrl),
    httpClient: client,
    converter: PolderConverter(uploads),
    authenticator: auth,
    interceptors: [errors, ?auth],
  );
}
