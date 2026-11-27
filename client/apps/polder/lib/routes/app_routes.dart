import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_core/models/group.dart";
import "package:calendar_views/calendar_views.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_ui/routes/sign_in_routes.dart";

export "package:polder_drive/routes/drive_routes.dart" show SharedSection;

abstract final class AppRoutes {
  static const login = "/login";
  static const files = DriveRoutes.files;
  static const notes = "/notes";
  static const calendar = "/calendar";
  static const search = "/search";
  static const scan = DriveRoutes.scan;
  static const pdf = DriveRoutes.pdf;
  static const media = DriveRoutes.media;
  static const editor = DriveRoutes.editor;
  static const cook = "/cook";
  static const activity = DriveRoutes.activity;
  static const sync = DriveRoutes.sync;
  static const conflicts = DriveRoutes.conflicts;
  static const autoUpload = DriveRoutes.autoUpload;
  static const trash = DriveRoutes.trash;
  static const shared = DriveRoutes.shared;
  static const groups = "/groups";
  static const tags = DriveRoutes.tags;
  static const publicShare = DriveRoutes.publicShare;
  static const settings = "/settings";
  static const generalSettings = "/settings/general";
  static const about = "/settings/about";
  static const account = "/settings/account";
  static const twoFactorSetup = "/two-factor-setup";

  static const admin = "/admin";
  static const adminOverview = "/admin/overview";
  static const adminUsers = "/admin/users";
  static const adminLogs = "/admin/logs";
  static const adminBranding = "/admin/branding";
  static const adminServer = "/admin/server";

  static const pathParameter = NotesLocations.pathParameter;
  static const selectParameter = DriveRoutes.selectParameter;
  static const queryParameter = "q";
  static const scopeParameter = "scope";
  static const serverParameter = DriveRoutes.serverParameter;
  static const fromParameter = SignInRoutes.fromParameter;

  static String filesAt(String path, {String? select}) => DriveRoutes.filesAt(path, select: select);

  static const notesLocations = NotesLocations(notes, cook: cook);

  static String noteAt(String path) => notesLocations.noteAt(path);

  static const calendarLocations = CalendarLocations(calendar);

  static String calendarAt(CalendarViewMode mode, DateTime date) => calendarLocations.dayAt(mode, date);

  static String calendarEventAt(EventRef ref, DateTime start) => calendarLocations.eventAt(ref, start);

  static String cookAt(String path) => notesLocations.cookAt(path);

  static bool isNoteLocation(String? location) => notesLocations.isNoteLocation(location);

  static String searchFor(String query) =>
      Uri(path: search, queryParameters: query.isEmpty ? null : {queryParameter: query}).toString();

  static String sharedSection(String section) => DriveRoutes.sharedSection(section);

  static String sharedAt(int shareId, {String path = "/"}) => DriveRoutes.sharedAt(shareId, path: path);

  static String federatedAt(int shareId, {String path = "/"}) => DriveRoutes.federatedAt(shareId, path: path);

  static String groupAt(int groupId, {GroupScope scope = GroupScope.mine}) =>
      Uri(path: "$groups/$groupId", queryParameters: _scopeQuery(scope)).toString();

  static String groupsScope({GroupScope scope = GroupScope.mine}) =>
      Uri(path: groups, queryParameters: _scopeQuery(scope)).toString();

  static GroupScope groupScopeOf(Uri uri) =>
      GroupScope.values.asNameMap()[uri.queryParameters[scopeParameter]] ?? GroupScope.mine;

  static Map<String, String>? _scopeQuery(GroupScope scope) =>
      scope == GroupScope.mine ? null : {scopeParameter: scope.name};

  static String publicShareAt(String code, {String? server, String path = "/"}) =>
      DriveRoutes.publicShareAt(code, server: server, path: path);

  static bool isPublic(String location) => DriveRoutes.isPublic(location);

  static const signIn = SignInRoutes(home: files, login: login, twoFactorSetup: twoFactorSetup, isPublic: isPublic);

  static String loginFrom(Uri location) => signIn.loginFrom(location);

  static String? safeReturn(String? location) => signIn.safeReturn(location);

  static String settingsPage(SettingsPage page) => "$settings/${page.name}";

  static String adminPage(AdminPage page) => "$admin/${page.name}";

  static bool isAdmin(String location) => location == admin || location.startsWith("$admin/");

  static String? upFrom(Uri location, {required bool single}) {
    final segments = location.pathSegments;
    return switch ("/${segments.firstOrNull ?? ""}") {
      groups when segments.length > 1 => single ? groupsScope(scope: groupScopeOf(location)) : files,
      settings || admin when segments.length > 1 => single ? "/${segments.first}" : files,
      _ => DriveRoutes.upFrom(location, single: single),
    };
  }

  static bool isTab(String location) =>
      [files, shared, notes, calendar].any((root) => location == root || location.startsWith(RegExp("$root[/?]")));

  static bool isTabRoot(Uri location, {required bool single}) {
    final up = upFrom(location, single: single);
    return up == null || Uri.parse(up).pathSegments.firstOrNull != location.pathSegments.firstOrNull;
  }
}

enum SettingsPage {
  general,
  apps,
  notifications,
  account,
  about;

  static SettingsPage? fromSegment(String? segment) => values.asNameMap()[segment];
}

enum AdminPage {
  overview,
  users,
  branding,
  mail,
  authentication,
  logs,
  server;

  static AdminPage? fromSegment(String? segment) => values.asNameMap()[segment];
}
