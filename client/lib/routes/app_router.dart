import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/account.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/scan_session.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/activity/activity_screen.dart";
import "package:polder/screens/admin/admin_logs_screen.dart";
import "package:polder/screens/admin/admin_overview_screen.dart";
import "package:polder/screens/admin/admin_shell.dart";
import "package:polder/screens/admin/admin_users_screen.dart";
import "package:polder/screens/auto_upload/auto_upload_screen.dart";
import "package:polder/screens/browser/browser_screen.dart";
import "package:polder/screens/login/login_screen.dart";
import "package:polder/screens/scan/scan_review_screen.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/screens/settings/about_screen.dart";
import "package:polder/screens/viewer/pdf_viewer_screen.dart";
import "package:polder/screens/settings/settings_screen.dart";
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
    refreshListenable: Listenable.merge([account, isAdmin]),
    redirect: (_, state) => AppRedirect.resolve(account.value, state.uri, isAdmin: isAdmin.value),
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
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
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsScreen(),
            routes: [GoRoute(path: "about", builder: (_, _) => const AboutScreen())],
          ),
        ],
      ),
      ShellRoute(
        builder: (_, state, child) => AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: AppRoutes.admin, builder: (_, _) => const AdminOverviewScreen()),
          GoRoute(path: AppRoutes.adminUsers, builder: (_, _) => const AdminUsersScreen()),
          GoRoute(path: AppRoutes.adminLogs, builder: (_, _) => const AdminLogsScreen()),
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
    final signedIn = account.value != null;
    final atLogin = location.path == AppRoutes.login;
    if (!signedIn && !atLogin) return AppRoutes.login;
    if (signedIn && atLogin) return AppRoutes.files;
    if (signedIn && !isAdmin && AppRoutes.isAdmin(location.path)) return AppRoutes.files;
    return null;
  }
}
