import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_ui/routes/sign_in_routes.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/screens/login/login_screen.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_ui/screens/two_factor/two_factor_setup_screen.dart";
import "package:polder_ui/widgets/navigation/standalone_shell.dart";

typedef LocationBuilder = Widget Function(Uri location);

GoRouter createStandaloneRouter(
  Ref ref, {
  required SignInRoutes signIn,
  required String settings,
  required String Function(BuildContext context) title,
  required LocationBuilder home,
  required LocationBuilder sidebar,
  required LocationBuilder rail,
  List<Widget> settingsGroups = const [],
  List<GoRoute> routes = const [],
}) {
  final state = SignInState(ref);
  final router = GoRouter(
    initialLocation: signIn.home,
    refreshListenable: state,
    redirect: (_, route) => signIn.redirect(state.snapshot, route.uri),
    routes: [
      standalonePage(signIn.login, (_) => const LoginScreen()),
      standalonePage(signIn.twoFactorSetup, (_) => const TwoFactorSetupScreen()),
      ShellRoute(
        builder: (context, route, child) => StandaloneShell(
          title: title(context),
          location: route.uri,
          sidebar: sidebar(route.uri),
          rail: rail(route.uri),
          child: child,
        ),
        routes: [
          standalonePage(signIn.home, (location) => UpScope(child: home(location))),
          standalonePage(settings, (_) => UpScope(child: StandaloneSettingsScreen(groups: settingsGroups))),
          ...routes,
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    state.dispose();
  });
  return router;
}

GoRoute standalonePage(String path, LocationBuilder page) => GoRoute(
  path: path,
  pageBuilder: (_, state) => MaterialPage<void>(key: state.pageKey, child: page(state.uri)),
);
