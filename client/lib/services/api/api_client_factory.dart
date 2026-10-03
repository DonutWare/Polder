import "package:http/http.dart" as http;

import "package:nomad/services/api/api_error_mapper.dart";
import "package:nomad/services/api/auth_interceptor.dart";
import "package:nomad/services/api/auth_session.dart";
import "package:nomad/services/api/generated/nomad.swagger.dart";
import "package:nomad/services/api/http_client.dart";
import "package:nomad/services/api/nomad_converter.dart";
import "package:nomad/services/api/pending_uploads.dart";

abstract final class ApiClientFactory {
  static Nomad create(String serverUrl, {AuthSession? session, http.Client? httpClient}) {
    final uploads = PendingUploads();
    final client = UploadingClient(httpClient ?? createHttpClient(), uploads);
    final auth = session == null
        ? null
        : AuthInterceptor(session: session, refreshApi: _service(serverUrl, client, uploads));
    return _service(serverUrl, client, uploads, auth);
  }

  static String normalizeServerUrl(String input) {
    final trimmed = input.trim().replaceAll(RegExp(r"/+$"), "");
    return trimmed.contains("://") ? trimmed : "https://$trimmed";
  }

  static Nomad _service(String serverUrl, http.Client client, PendingUploads uploads, [AuthInterceptor? auth]) =>
      Nomad.create(
        baseUrl: Uri.parse(serverUrl),
        httpClient: client,
        converter: NomadConverter(uploads),
        authenticator: auth,
        interceptors: [const ApiErrorInterceptor(), ?auth],
      );
}
