import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_account_link/companion_app.dart";
import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder_drive/providers/sync/conflict_queue_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_ui/routes/history_back.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/screens/shell/shell_destination_labels.dart";
import "package:polder/screens/shell/sync_background_activator.dart";
import "package:polder/screens/shell/widgets/file_operations_bar.dart";
import "package:polder/screens/shell/widgets/more_options.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder/widgets/auth/login_approval_dialog.dart";
import "package:polder_ui/widgets/auth/two_factor_deadline_banner.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/navigation/intercept_back.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";
import "package:polder_ui/widgets/shared/quota_bar.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(shellDestinationsProvider);
    final stacked = ref.watch(stackedDestinationsProvider);
    final conflicts = ref.watch(conflictQueueProvider.select((queue) => queue.conflicts.length));
    final activity = ref.watch(activityBadgeProvider);
    final name = ref.watch(brandingProvider.select((branding) => branding.nameOr(context.localized.appTitle)));
    final router = GoRouter.of(context);
    final top = router.state.uri;
    final location = top.path;
    final canExit =
        !router.canPop() &&
        AppRoutes.upFrom(top, single: true) == null &&
        HistoryBack.previousFrom(context, location: top.toString()) == null;
    bool showsDestination(ShellDestination destination) =>
        location == destination.route || location.startsWith("${destination.route}/");
    return ListenableBuilder(
      listenable: InterceptBack.changes,
      builder: (context, child) => PopScope(canPop: canExit && !InterceptBack.hasInterceptors, child: child!),
      child: SyncBackgroundActivator(
        child: SideSheetDrawer(
          title: name,
          sheet: const MoreOptions(),
          canEdgeSwipe: () =>
              AdaptiveLayout.isPhone(context) &&
              !router.canPop() &&
              AppRoutes.isTabRoot(router.state.uri, single: AdaptiveLayout.isSingle(context)),
          child: NavigationShell(
            showNavigation: AppRoutes.isTab(top.toString()) || !AdaptiveLayout.isSingle(context),
            items: [
              for (final destination in destinations)
                destination.item(context, opensApp: ref.watch(opensCompanionProvider(destination))),
            ],
            launchers: [
              for (final destination in stacked)
                destination.item(
                  context,
                  badge: switch (destination) {
                    ShellDestination.activity => activity,
                    ShellDestination.sync when conflicts > 0 => "$conflicts",
                    _ => null,
                  },
                ),
            ],
            selectedIndex: destinations.indexWhere(showsDestination),
            selectedLauncher: stacked.indexWhere(showsDestination),
            onSelected: (index) {
              final destination = destinations[index];
              if (ref.read(opensCompanionProvider(destination))) {
                return unawaited(_openCompanion(context, ref, destination));
              }
              final reselectedFiles = destination == ShellDestination.files && showsDestination(destination);
              context.go(reselectedFiles ? AppRoutes.filesAt(RemotePath.root) : destination.route);
            },
            onLaunch: (index) {
              final destination = stacked[index];
              if (showsDestination(destination)) return goWithin(context, destination.route);
              unawaited(context.push(destination.route));
            },
            sidebarFooter: const QuotaBar(),
            child: LoginApprovalListener(
              child: Column(
                children: [
                  const TwoFactorDeadlineBanner(),
                  Expanded(
                    child: FileOperationsOverlay(child: SearchShortcut(child: child)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openCompanion(BuildContext context, WidgetRef ref, ShellDestination destination) async {
  final feature = destination.feature!;
  if (await CompanionApps.open(feature.companion, dev: isDevFlavor)) return;
  await ref.read(installedCompanionsProvider.notifier).refresh();
  if (!context.mounted) return;
  if (ref.read(resolvedFeatureModesProvider).isBuiltIn(feature)) return context.go(destination.route);
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(context.localized.companionAppUnavailable)));
}
