abstract final class AppRoutes {
  static const login = "/login";
  static const files = "/files";
  static const search = "/search";
  static const scan = "/scan";
  static const pdf = "/pdf";
  static const activity = "/activity";
  static const sync = "/sync";
  static const conflicts = "/sync/conflicts";
  static const autoUpload = "/auto-upload";
  static const trash = "/trash";
  static const settings = "/settings";
  static const about = "/settings/about";

  static const admin = "/admin";
  static const adminUsers = "/admin/users";
  static const adminLogs = "/admin/logs";

  static const pathParameter = "path";
  static const selectParameter = "select";
  static const queryParameter = "q";

  static String filesAt(String path, {String? select}) =>
      Uri(path: files, queryParameters: {pathParameter: path, selectParameter: ?select}).toString();

  static String searchFor(String query) =>
      Uri(path: search, queryParameters: query.isEmpty ? null : {queryParameter: query}).toString();

  static bool isAdmin(String location) => location == admin || location.startsWith("$admin/");
}
