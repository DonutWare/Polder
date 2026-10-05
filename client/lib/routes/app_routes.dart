abstract final class AppRoutes {
  static const login = "/login";
  static const files = "/files";
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

  static const pathParameter = "path";

  static String filesAt(String path) => Uri(path: files, queryParameters: {pathParameter: path}).toString();

  static bool isAdmin(String location) => location == admin || location.startsWith("$admin/");
}
