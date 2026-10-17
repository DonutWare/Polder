import "package:polder/models/sharing.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/remote_path.dart";

class ShareLinkTarget {
  const ShareLinkTarget({required this.serverUrl, required this.code});

  static const schemes = {"polder", "polder-dev"};
  static final _code = RegExp(r"^[0-9A-Za-z]{6,32}$");

  final String serverUrl;
  final String code;

  static ShareLinkTarget? parse(Uri uri) {
    if (!schemes.contains(uri.scheme) || uri.host != "share") return null;
    final server = uri.queryParameters["server"];
    final code = uri.queryParameters["code"];
    if (server == null || server.trim().isEmpty || code == null || !_code.hasMatch(code)) return null;
    return ShareLinkTarget(serverUrl: ApiClientFactory.normalizeServerUrl(server), code: code);
  }

  Uri get appUri => Uri(scheme: "polder", host: "share", queryParameters: {"server": serverUrl, "code": code});

  bool isOn(String? accountServer) =>
      accountServer != null && ApiClientFactory.normalizeServerUrl(accountServer) == serverUrl;

  String get publicLocation => AppRoutes.publicShareAt(code, server: serverUrl);

  Future<String> locationFor(PolderApi? signedInApi) async {
    if (signedInApi == null) return publicLocation;
    final LinkMatch match;
    try {
      match = await signedInApi.matchShareLink(code);
    } on ApiException {
      return publicLocation;
    }
    if (match.ownPath case final ownPath?) {
      return ownPath == RemotePath.root
          ? AppRoutes.filesAt(RemotePath.root)
          : AppRoutes.filesAt(RemotePath.parent(ownPath), select: RemotePath.name(ownPath));
    }
    if (match.shareId case final shareId?) return AppRoutes.sharedAt(shareId, path: match.path ?? RemotePath.root);
    return publicLocation;
  }
}
