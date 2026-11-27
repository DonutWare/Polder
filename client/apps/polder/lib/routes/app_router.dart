import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_drive/routes/drive_router_routes.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder/routes/route_extra_codec.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder/screens/admin/admin_screen.dart";
import "package:polder_ui/screens/login/login_screen.dart";
import "package:polder_notes/screens/notes/cooking/cooking_screen.dart";
import "package:polder_notes/screens/notes/notes_screen.dart";
import "package:polder_calendar/screens/calendar/calendar_screen.dart";
import "package:polder_drive/screens/search/open_search.dart";
import "package:polder/screens/settings/settings_screen.dart";
import "package:polder_ui/screens/two_factor/two_factor_setup_screen.dart";
import "package:polder/screens/groups/groups_screen.dart";
import "package:polder/screens/shell/app_shell.dart";
import "package:polder/screens/shell/sync_background_activator.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/routes/sign_in_routes.dart";

final routerProvider = Provider<GoRouter>((ref) {
  final account = ValueNotifier<AsyncValue<Account?>>(ref.read(accountProvider));
  final isAdmin = ValueNotifier<bool>(ref.read(isAdminProvider));
  final continueOffline = ValueNotifier<bool>(ref.read(continueOfflineProvider));
  final twoFactorSetup = ValueNotifier<bool>(ref.read(twoFactorSetupRequiredProvider));
  final features = ValueNotifier<FeatureModes>(ref.read(resolvedFeatureModesProvider));
  final browsed = BrowsedPathMemory();
  ref.listen(accountProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id) browsed.path = RemotePath.root;
    account.value = next;
  });
  ref.listen(isAdminProvider, (_, next) => isAdmin.value = next);
  ref.listen(continueOfflineProvider, (_, next) => continueOffline.value = next);
  ref.listen(twoFactorSetupRequiredProvider, (_, next) => twoFactorSetup.value = next);
  ref.listen(resolvedFeatureModesProvider, (_, next) => features.value = next);
  final router = GoRouter(
    initialLocation: AppRoutes.files,
    extraCodec: const RouteExtraCodec(),
    refreshListenable: Listenable.merge([account, isAdmin, continueOffline, twoFactorSetup, features]),
    redirect: (_, state) => AppRedirect.resolve(
      account.value,
      state.uri,
      isAdmin: isAdmin.value,
      continueOffline: continueOffline.value,
      twoFactorSetupRequired: twoFactorSetup.value,
      features: features.value,
    ),
    routes: [
      _route(path: AppRoutes.login, page: (_) => const LoginScreen()),
      _route(path: AppRoutes.twoFactorSetup, page: (_) => const TwoFactorSetupScreen()),
      ...driveFullScreenRoutes(),
      _route(
        path: AppRoutes.cook,
        redirect: (_, state) => state.uri.queryParameters.containsKey(AppRoutes.pathParameter) ? null : AppRoutes.notes,
        page: (state) => _standalone(CookingScreen(path: state.uri.queryParameters[AppRoutes.pathParameter]!)),
      ),
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          ...driveShellRoutes(browsed),
          _tab(
            path: AppRoutes.notes,
            page: (state) => UpScope(child: NotesScreen(notePath: state.uri.queryParameters[AppRoutes.pathParameter])),
          ),
          _tab(
            path: AppRoutes.calendar,
            page: (state) => UpScope(child: CalendarScreen.at(state.uri)),
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
    twoFactorSetup.dispose();
  });
  return router;
});

abstract final class AppRedirect {
  static String? resolve(
    AsyncValue<Account?> account,
    Uri location, {
    bool isAdmin = false,
    bool continueOffline = false,
    bool twoFactorSetupRequired = false,
    FeatureModes features = FeatureModes.everythingBuiltIn,
  }) {
    final snapshot = SignInSnapshot(
      account: account,
      continueOffline: continueOffline,
      twoFactorSetupRequired: twoFactorSetupRequired,
    );
    final signInRedirect = AppRoutes.signIn.redirect(snapshot, location);
    if (signInRedirect != null) return signInRedirect;
    if (account.isLoading && !account.hasValue) return null;
    if (account.value == null) return null;
    if (!isAdmin && AppRoutes.isAdmin(location.path)) return home(features);
    final feature = featureOf(location.path);
    if (feature != null && !features.isBuiltIn(feature)) return home(features);
    return null;
  }

  static String home(FeatureModes features) => switch (features) {
    _ when features.isBuiltIn(PolderFeature.drive) => AppRoutes.files,
    _ when features.isBuiltIn(PolderFeature.notes) => AppRoutes.notes,
    _ when features.isBuiltIn(PolderFeature.calendar) => AppRoutes.calendar,
    _ => AppRoutes.settingsPage(SettingsPage.apps),
  };

  static PolderFeature? featureOf(String path) {
    bool under(String route) => path == route || path.startsWith("$route/");
    if (under(AppRoutes.cook)) return PolderFeature.notes;
    for (final destination in ShellDestination.values) {
      if (destination.feature != null && under(destination.route)) return destination.feature;
    }
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
