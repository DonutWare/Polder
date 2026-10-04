import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/activity/live_transfers_provider.dart";
import "package:nomad/providers/shell/shell_destinations_provider.dart";
import "package:nomad/providers/sync/conflict_queue_provider.dart";
import "package:nomad/routes/app_routes.dart";
import "package:nomad/screens/shell/shell_destination_labels.dart";
import "package:nomad/screens/shell/sync_background_activator.dart";
import "package:nomad/screens/shell/widgets/more_options.dart";
import "package:nomad/util/extensions/num_extensions.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/util/remote_path.dart";
import "package:nomad/widgets/layout/adaptive.dart";
import "package:nomad/widgets/navigation/navigation_shell.dart";
import "package:nomad/widgets/shared/quota_bar.dart";

class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(shellDestinationsProvider);
    final secondary = ref.watch(secondaryShellDestinationsProvider);
    final all = [...destinations, ...secondary];
    final conflicts = ref.watch(conflictQueueProvider.select((queue) => queue.conflicts.length));
    final uploading = ref.watch(incomingPathsProvider.select((paths) => paths.length));
    final account = ref.watch(currentAccountProvider);
    return SyncBackgroundActivator(
      child: SideSheetDrawer(
        title: context.localized.appTitle,
        sheet: const MoreOptions(),
        canEdgeSwipe: () => WindowSize.of(context) == WindowSize.compact && !GoRouter.of(context).canPop(),
        child: NavigationShell(
          items: [
            for (final destination in destinations)
              destination.item(
                context,
                badge: switch (destination) {
                  ShellDestination.sync when conflicts > 0 => "$conflicts",
                  ShellDestination.activity when uploading > 0 => uploading.shortenToNearestNumber(),
                  _ => null,
                },
              ),
          ],
          secondaryItems: [for (final destination in secondary) destination.item(context)],
          selectedIndex: all.indexWhere((destination) => location.startsWith(destination.route)),
          onSelected: (index) {
            final destination = all[index];
            final reselectedFiles = destination == ShellDestination.files && location.startsWith(destination.route);
            context.go(reselectedFiles ? AppRoutes.filesAt(RemotePath.root) : destination.route);
          },
          title: account?.user.username ?? context.localized.appTitle,
          subtitle: account == null ? "" : Uri.tryParse(account.serverUrl)?.host ?? account.serverUrl,
          markIcon: IconsaxPlusBold.cloud,
          sidebarFooter: const QuotaBar(),
          child: child,
        ),
      ),
    );
  }
}
