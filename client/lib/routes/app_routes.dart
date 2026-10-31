import "package:polder/models/group.dart";
import "package:polder/util/remote_path.dart";

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
  static const tags = "/tags";
  static const publicShare = "/share";
  static const settings = "/settings";
  static const generalSettings = "/settings/general";
  static const about = "/settings/about";
  static const account = "/settings/account";

  static const admin = "/admin";
  static const adminOverview = "/admin/overview";
  static const adminUsers = "/admin/users";
  static const adminLogs = "/admin/logs";
  static const adminBranding = "/admin/branding";
  static const adminServer = "/admin/server";

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

  static String settingsPage(SettingsPage page) => "$settings/${page.name}";

  static String adminPage(AdminPage page) => "$admin/${page.name}";

  static bool isAdmin(String location) => location == admin || location.startsWith("$admin/");

  static String? upFrom(Uri location, {required bool single}) {
    final segments = location.pathSegments;
    final path = location.queryParameters[pathParameter] ?? RemotePath.root;
    return switch ("/${segments.firstOrNull ?? ""}") {
      files => path == RemotePath.root ? null : filesAt(RemotePath.parent(path)),
      shared => _sharedUp(segments, path, single: single),
      groups when segments.length > 1 => single ? groupsScope(scope: groupScopeOf(location)) : files,
      settings || admin when segments.length > 1 => single ? "/${segments.first}" : files,
      sync when segments.length > 1 => sync,
      _ => files,
    };
  }

  static bool isTab(String location) =>
      [files, shared, notes, sync].any((root) => location == root || location.startsWith(RegExp("$root[/?]")));

  static bool isTabRoot(Uri location, {required bool single}) {
    final up = upFrom(location, single: single);
    return up == null || Uri.parse(up).pathSegments.firstOrNull != location.pathSegments.firstOrNull;
  }

  static String _sharedUp(List<String> segments, String path, {required bool single}) {
    final section = SharedSection.fromSegment(segments.elementAtOrNull(1));
    final shareId = int.tryParse(segments.elementAtOrNull(2) ?? "");
    if (section == null) return files;
    if (shareId == null) return single ? shared : files;
    final federated = section == SharedSection.federated;
    final rootSection = federated ? SharedSection.federated : SharedSection.withMe;
    if (path == RemotePath.root) return sharedSection(rootSection.segment);
    final parent = RemotePath.parent(path);
    return federated ? federatedAt(shareId, path: parent) : sharedAt(shareId, path: parent);
  }
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

enum SettingsPage {
  general,
  account,
  about;

  static SettingsPage? fromSegment(String? segment) => values.asNameMap()[segment];
}

enum AdminPage {
  overview,
  users,
  branding,
  logs,
  server;

  static AdminPage? fromSegment(String? segment) => values.asNameMap()[segment];
}
