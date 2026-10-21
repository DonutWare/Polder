import "package:polder/models/group.dart";

abstract final class AppRoutes {
  static const login = "/login";
  static const files = "/files";
  static const notes = "/notes";
  static const search = "/search";
  static const scan = "/scan";
  static const pdf = "/pdf";
  static const editor = "/editor";
  static const activity = "/activity";
  static const sync = "/sync";
  static const conflicts = "/sync/conflicts";
  static const autoUpload = "/auto-upload";
  static const trash = "/trash";
  static const shared = "/shared";
  static const groups = "/groups";
  static const publicShare = "/share";
  static const settings = "/settings";
  static const about = "/settings/about";
  static const account = "/settings/account";

  static const admin = "/admin";
  static const adminUsers = "/admin/users";
  static const adminLogs = "/admin/logs";
  static const adminBranding = "/admin/branding";

  static const pathParameter = "path";
  static const selectParameter = "select";
  static const queryParameter = "q";
  static const scopeParameter = "scope";
  static const serverParameter = "server";
  static const fromParameter = "from";

  static String filesAt(String path, {String? select}) =>
      Uri(path: files, queryParameters: {pathParameter: path, selectParameter: ?select}).toString();

  static String noteAt(String path) => Uri(path: notes, queryParameters: {pathParameter: path}).toString();

  static bool isNoteLocation(String? location) {
    final uri = location == null ? null : Uri.tryParse(location);
    return uri != null && uri.path == notes && uri.queryParameters.containsKey(pathParameter);
  }

  static String searchFor(String query) =>
      Uri(path: search, queryParameters: query.isEmpty ? null : {queryParameter: query}).toString();

  static String sharedSection(String section) => "$shared/$section";

  static String sharedAt(int shareId, {String path = "/"}) => Uri(
    path: "$shared/${SharedSection.withMe.segment}/$shareId",
    queryParameters: path == "/" ? null : {pathParameter: path},
  ).toString();

  static String federatedAt(int shareId, {String path = "/"}) => Uri(
    path: "$shared/${SharedSection.federated.segment}/$shareId",
    queryParameters: path == "/" ? null : {pathParameter: path},
  ).toString();

  static String groupAt(int groupId, {GroupScope scope = GroupScope.mine}) =>
      Uri(path: "$groups/$groupId", queryParameters: _scopeQuery(scope)).toString();

  static String groupsScope({GroupScope scope = GroupScope.mine}) =>
      Uri(path: groups, queryParameters: _scopeQuery(scope)).toString();

  static GroupScope groupScopeOf(Uri uri) =>
      GroupScope.values.asNameMap()[uri.queryParameters[scopeParameter]] ?? GroupScope.mine;

  static Map<String, String>? _scopeQuery(GroupScope scope) =>
      scope == GroupScope.mine ? null : {scopeParameter: scope.name};

  static String publicShareAt(String code, {String? server, String path = "/"}) {
    final parameters = {serverParameter: ?server, if (path != "/") pathParameter: path};
    return Uri(path: "$publicShare/$code", queryParameters: parameters.isEmpty ? null : parameters).toString();
  }

  static bool isPublic(String location) => location.startsWith("$publicShare/");

  static String loginFrom(Uri location) => location.path == files && location.query.isEmpty
      ? login
      : Uri(path: login, queryParameters: {fromParameter: location.toString()}).toString();

  static String? safeReturn(String? location) =>
      location != null && location.startsWith("/") && !location.startsWith("//") && !location.startsWith(login)
      ? location
      : null;

  static bool isAdmin(String location) => location == admin || location.startsWith("$admin/");
}

enum SharedSection {
  withMe("with-me"),
  byMe("by-me"),
  links("links"),
  federated("other-servers");

  const SharedSection(this.segment);

  final String segment;

  static SharedSection? fromSegment(String? segment) =>
      SharedSection.values.where((section) => section.segment == segment).firstOrNull;
}
