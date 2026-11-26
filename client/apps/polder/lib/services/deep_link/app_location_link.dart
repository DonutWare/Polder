import "package:polder/routes/app_routes.dart";
import "package:polder/services/deep_link/share_link_target.dart";

abstract final class AppLocationLink {
  static const host = "open";
  static const _pathParameter = "path";

  static Uri uriFor(String location) => Uri(scheme: "polder", host: host, queryParameters: {_pathParameter: location});

  static String? locationOf(Uri uri) {
    if (!ShareLinkTarget.isAppUri(uri, host: host)) return null;
    return AppRoutes.safeReturn(uri.queryParameters[_pathParameter]);
  }
}
