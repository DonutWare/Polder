import "package:flutter/material.dart";

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
import "package:polder/routes/up_scope.dart";
import "package:polder/screens/activity/activity_screen.dart";
import "package:polder/screens/admin/admin_screen.dart";
import "package:polder/screens/auto_upload/auto_upload_screen.dart";
import "package:polder/screens/browser/browser_stack.dart";
import "package:polder/screens/login/login_screen.dart";
import "package:polder/screens/notes/notes_screen.dart";
import "package:polder/screens/scan/scan_review_screen.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/screens/viewer/document_editor_screen.dart";
import "package:polder/screens/viewer/pdf_viewer_screen.dart";
import "package:polder/screens/settings/settings_screen.dart";
import "package:polder/screens/public_share/public_share_screen.dart";
import "package:polder/screens/groups/groups_screen.dart";
import "package:polder/screens/tags/tags_screen.dart";
import "package:polder/screens/shared/shared_screen.dart";
import "package:polder/screens/shell/app_shell.dart";
import "package:polder/screens/shell/sync_background_activator.dart";
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
      _route(path: AppRoutes.login, page: (_) => const LoginScreen()),
      _route(
        path: "${AppRoutes.publicShare}/:code",
        page: (state) => PublicShareScreen(
          code: state.pathParameters["code"]!,
          server: state.uri.queryParameters[AppRoutes.serverParameter],
          path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
        ),
      ),
      _route(
        path: AppRoutes.scan,
        redirect: (_, state) => state.extra is ScanRequest ? null : AppRoutes.files,
        page: (state) => ScanReviewScreen(request: state.extra! as ScanRequest),
      ),
      _route(
        path: AppRoutes.pdf,
        redirect: (_, state) => state.extra is FileEntry ? null : AppRoutes.files,
        page: (state) => PdfViewerScreen(entry: state.extra! as FileEntry),
      ),
      _route(
        path: AppRoutes.editor,
        redirect: (_, state) => state.extra is FileEntry || state.extra is EditorTarget ? null : AppRoutes.files,
        page: (state) => DocumentEditorScreen(
          target: switch (state.extra) {
            final EditorTarget target => target,
            final extra => EditorTarget(extra! as FileEntry),
          },
        ),
      ),
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          _tab(
            path: AppRoutes.files,
            redirect: (_, state) {
              final path = state.uri.queryParameters[AppRoutes.pathParameter];
              if (path == null) return AppRoutes.filesAt(lastBrowsedPath);
              lastBrowsedPath = path;
              return null;
            },
            page: (state) => UpScope(
              child: BrowserStack(
                path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
                select: state.uri.queryParameters[AppRoutes.selectParameter],
              ),
            ),
          ),
          _tab(
            path: AppRoutes.notes,
            page: (state) => UpScope(child: NotesScreen(notePath: state.uri.queryParameters[AppRoutes.pathParameter])),
          ),
          _tab(
            path: AppRoutes.sync,
            page: (_) => const UpScope(child: SyncFoldersScreen()),
            routes: [
              _route(
                path: "conflicts",
                page: (_) => const UpScope(child: ConflictResolverScreen()),
              ),
            ],
          ),
          _tab(
            path: AppRoutes.shared,
            page: (_) => const UpScope(child: SharedScreen()),
          ),
          _tab(
            path: "${AppRoutes.shared}/:section",
            redirect: (_, state) =>
                SharedSection.fromSegment(state.pathParameters["section"]) == null ? AppRoutes.shared : null,
            page: (state) =>
                UpScope(child: SharedScreen(section: SharedSection.fromSegment(state.pathParameters["section"]))),
          ),
          _tab(
            path: "${AppRoutes.shared}/:section/:shareId",
            redirect: (_, state) =>
                !_browsableSections.contains(SharedSection.fromSegment(state.pathParameters["section"])) ||
                    int.tryParse(state.pathParameters["shareId"] ?? "") == null
                ? AppRoutes.shared
                : null,
            page: (state) => UpScope(
              child: SharedScreen(
                section: SharedSection.fromSegment(state.pathParameters["section"]),
                shareId: int.parse(state.pathParameters["shareId"]!),
                path: state.uri.queryParameters[AppRoutes.pathParameter] ?? RemotePath.root,
              ),
            ),
          ),
          _route(
            path: AppRoutes.activity,
            page: (_) => const UpScope(child: ActivityScreen()),
          ),
          _route(
            path: AppRoutes.autoUpload,
            page: (_) => const UpScope(child: AutoUploadScreen()),
          ),
          _route(
            path: AppRoutes.trash,
            page: (_) => const UpScope(child: TrashScreen()),
          ),
          _route(
            path: AppRoutes.tags,
            page: (_) => const UpScope(child: TagsScreen()),
          ),
          _route(
            path: AppRoutes.groups,
            family: "groups",
            page: (state) => UpScope(child: GroupsScreen(scope: AppRoutes.groupScopeOf(state.uri))),
          ),
          _route(
            path: "${AppRoutes.groups}/:groupId",
            family: "groups",
            redirect: (_, state) =>
                int.tryParse(state.pathParameters["groupId"] ?? "") == null ? AppRoutes.groups : null,
            page: (state) => UpScope(
              child: GroupsScreen(
                scope: AppRoutes.groupScopeOf(state.uri),
                groupId: int.parse(state.pathParameters["groupId"]!),
              ),
            ),
          ),
          _route(
            path: AppRoutes.settings,
            family: "settings",
            page: (_) => const UpScope(child: SettingsScreen()),
          ),
          _route(
            path: "${AppRoutes.settings}/:page",
            family: "settings",
            redirect: (_, state) =>
                SettingsPage.fromSegment(state.pathParameters["page"]) == null ? AppRoutes.settings : null,
            page: (state) =>
                UpScope(child: SettingsScreen(page: SettingsPage.fromSegment(state.pathParameters["page"]))),
          ),
          _route(
            path: AppRoutes.admin,
            family: "admin",
            page: (_) => const UpScope(child: AdminScreen()),
          ),
          _route(
            path: "${AppRoutes.admin}/:page",
            family: "admin",
            redirect: (_, state) =>
                AdminPage.fromSegment(state.pathParameters["page"]) == null ? AppRoutes.admin : null,
            page: (state) => UpScope(child: AdminScreen(page: AdminPage.fromSegment(state.pathParameters["page"]))),
          ),
        ],
      ),
      _route(
        path: AppRoutes.search,
        page: (state) =>
            _standalone(SearchScreen(initialQuery: state.uri.queryParameters[AppRoutes.queryParameter] ?? "")),
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

GoRoute _route({
  required String path,
  required Widget Function(GoRouterState state) page,
  String? family,
  GoRouterRedirect? redirect,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  redirect: redirect,
  routes: routes,
  pageBuilder: (_, state) => MaterialPage<void>(key: _pageKey(state, family), name: state.path, child: page(state)),
);

LocalKey _pageKey(GoRouterState state, String? family) =>
    family != null && _isDeclarative(state) ? ValueKey("family:$family") : state.pageKey;

bool _isDeclarative(GoRouterState state) => state.pageKey.value.startsWith("/");

GoRoute _tab({
  required String path,
  required Widget Function(GoRouterState state) page,
  GoRouterRedirect? redirect,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  redirect: redirect,
  routes: routes,
  pageBuilder: (_, state) =>
      NoTransitionPage<void>(key: ValueKey("tab:${state.uri.pathSegments.firstOrNull}"), child: page(state)),
);

Widget _standalone(Widget page) => SyncBackgroundActivator(
  child: SearchShortcut(child: UpScope(child: page)),
);

const _browsableSections = {SharedSection.withMe, SharedSection.federated};
