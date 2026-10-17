import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/account.dart";
import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/scan_session.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/route_extra_codec.dart";
import "package:polder/screens/activity/activity_screen.dart";
import "package:polder/screens/admin/admin_branding_screen.dart";
import "package:polder/screens/admin/admin_logs_screen.dart";
import "package:polder/screens/admin/admin_overview_screen.dart";
import "package:polder/screens/admin/admin_shell.dart";
import "package:polder/screens/admin/admin_users_screen.dart";
import "package:polder/screens/auto_upload/auto_upload_screen.dart";
import "package:polder/screens/browser/browser_screen.dart";
import "package:polder/screens/login/login_screen.dart";
import "package:polder/screens/notes/notes_screen.dart";
import "package:polder/screens/scan/scan_review_screen.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/screens/settings/about_screen.dart";
import "package:polder/screens/settings/account_screen.dart";
import "package:polder/screens/viewer/document_editor_screen.dart";
import "package:polder/screens/viewer/pdf_viewer_screen.dart";
import "package:polder/screens/settings/settings_screen.dart";
import "package:polder/screens/public_share/public_share_screen.dart";
import "package:polder/screens/groups/groups_screen.dart";
import "package:polder/screens/shared/shared_screen.dart";
import "package:polder/screens/shell/app_shell.dart";
import "package:polder/screens/sync/conflict_resolver_screen.dart";
import "package:polder/screens/sync/sync_folders_screen.dart";
import "package:polder/screens/trash/trash_screen.dart";
import "package:polder/util/remote_path.dart";

final routerProvider = Provider<GoRouter>((ref) {
  final account = ValueNotifier<AsyncValue<Account?>>(ref.read(accountProvider));
  final isAdmin = ValueNotifier<bool>(ref.read(isAdminProvider));
  var lastBrowsedPath = RemotePath.root;
  ref.listen(accountProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id) lastBrowsedPath = RemotePath.root;
    account.value = next;
  });
  ref.listen(isAdminProvider, (_, next) => isAdmin.value = next);
  final router = GoRouter(
    initialLocation: AppRoutes.files,
    extraCodec: const RouteExtraCodec(),
    refreshListenable: Listenable.merge([account, isAdmin]),
    redirect: (_, state) => AppRedirect.resolve(account.value, state.uri, isAdmin: isAdmin.value),
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: "${AppRoutes.publicShare}/:code",
        builder: (_, state) => PublicShareScreen(
          code: state.pathParameters["code"]!,
          server: state.uri.queryParameters[AppRoutes.serverParameter],
          path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
        ),
      ),
      GoRoute(
        path: AppRoutes.scan,
        redirect: (_, state) => state.extra is ScanRequest ? null : AppRoutes.files,
        builder: (_, state) => ScanReviewScreen(request: state.extra! as ScanRequest),
      ),
      GoRoute(
        path: AppRoutes.pdf,
        redirect: (_, state) => state.extra is FileEntry ? null : AppRoutes.files,
        builder: (_, state) => PdfViewerScreen(entry: state.extra! as FileEntry),
      ),
      GoRoute(
        path: AppRoutes.editor,
        redirect: (_, state) => state.extra is FileEntry || state.extra is EditorTarget ? null : AppRoutes.files,
        builder: (_, state) => DocumentEditorScreen(
          target: switch (state.extra) {
            final EditorTarget target => target,
            final extra => EditorTarget(extra! as FileEntry),
          },
        ),
      ),
      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.files,
            redirect: (_, state) {
              final path = state.uri.queryParameters[AppRoutes.pathParameter];
              if (path == null) return AppRoutes.filesAt(lastBrowsedPath);
              lastBrowsedPath = path;
              return null;
            },
            builder: (_, state) => BrowserScreen(
              path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
              select: state.uri.queryParameters[AppRoutes.selectParameter],
            ),
          ),
          GoRoute(
            path: AppRoutes.notes,
            builder: (_, state) => NotesScreen(notePath: state.uri.queryParameters[AppRoutes.pathParameter]),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (_, state) =>
                SearchScreen(initialQuery: state.uri.queryParameters[AppRoutes.queryParameter] ?? ""),
          ),
          GoRoute(path: AppRoutes.activity, builder: (_, _) => const ActivityScreen()),
          GoRoute(
            path: AppRoutes.sync,
            builder: (_, _) => const SyncFoldersScreen(),
            routes: [GoRoute(path: "conflicts", builder: (_, _) => const ConflictResolverScreen())],
          ),
          GoRoute(path: AppRoutes.autoUpload, builder: (_, _) => const AutoUploadScreen()),
          GoRoute(path: AppRoutes.trash, builder: (_, _) => const TrashScreen()),
          GoRoute(path: AppRoutes.shared, builder: (_, _) => const SharedScreen()),
          GoRoute(
            path: "${AppRoutes.shared}/:section",
            redirect: (_, state) =>
                SharedSection.fromSegment(state.pathParameters["section"]) == null ? AppRoutes.shared : null,
            builder: (_, state) => SharedScreen(section: SharedSection.fromSegment(state.pathParameters["section"])),
          ),
          GoRoute(
            path: "${AppRoutes.shared}/:section/:shareId",
            redirect: (_, state) =>
                state.pathParameters["section"] != SharedSection.withMe.segment ||
                    int.tryParse(state.pathParameters["shareId"] ?? "") == null
                ? AppRoutes.shared
                : null,
            builder: (_, state) => SharedScreen(
              section: SharedSection.withMe,
              shareId: int.parse(state.pathParameters["shareId"]!),
              path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
            ),
          ),
          GoRoute(
            path: AppRoutes.groups,
            builder: (_, state) => GroupsScreen(scope: AppRoutes.groupScopeOf(state.uri)),
          ),
          GoRoute(
            path: "${AppRoutes.groups}/:groupId",
            redirect: (_, state) =>
                int.tryParse(state.pathParameters["groupId"] ?? "") == null ? AppRoutes.groups : null,
            builder: (_, state) => GroupsScreen(
              scope: AppRoutes.groupScopeOf(state.uri),
              groupId: int.parse(state.pathParameters["groupId"]!),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsScreen(),
            routes: [
              GoRoute(path: "about", builder: (_, _) => const AboutScreen()),
              GoRoute(path: "account", builder: (_, _) => const AccountScreen()),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (_, state, child) => AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: AppRoutes.admin, builder: (_, _) => const AdminOverviewScreen()),
          GoRoute(path: AppRoutes.adminUsers, builder: (_, _) => const AdminUsersScreen()),
          GoRoute(path: AppRoutes.adminLogs, builder: (_, _) => const AdminLogsScreen()),
          GoRoute(path: AppRoutes.adminBranding, builder: (_, _) => const AdminBrandingScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    account.dispose();
    isAdmin.dispose();
  });
  return router;
});

abstract final class AppRedirect {
  static String? resolve(AsyncValue<Account?> account, Uri location, {bool isAdmin = false}) {
    if (account.isLoading && !account.hasValue) return null;
    if (AppRoutes.isPublic(location.path)) return null;
    final signedIn = account.value != null;
    final atLogin = location.path == AppRoutes.login;
    if (!signedIn && !atLogin) return AppRoutes.loginFrom(location);
    if (signedIn && atLogin) {
      return AppRoutes.safeReturn(location.queryParameters[AppRoutes.fromParameter]) ?? AppRoutes.files;
    }
    if (signedIn && !isAdmin && AppRoutes.isAdmin(location.path)) return AppRoutes.files;
    return null;
  }
}
