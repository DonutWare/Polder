import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/screens/shell/shell_destination_labels.dart";
import "package:polder/screens/shell/widgets/more_options.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/navigation/app_mark.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";

/// Server administration, kept apart from the everyday app so its tools stay out of the way.
class AdminShell extends ConsumerWidget {
  const AdminShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl)) ?? "";
    final selected = AdminDestination.values.lastIndexWhere((destination) => location.startsWith(destination.route));
    return SideSheetDrawer(
      title: context.localized.administration,
      sheet: const MoreOptions(inAdministration: true),
      canEdgeSwipe: () => WindowSize.of(context) == WindowSize.compact && !GoRouter.of(context).canPop(),
      child: NavigationShell(
        items: [for (final destination in AdminDestination.values) destination.item(context)],
        selectedIndex: selected < 0 ? 0 : selected,
        onSelected: (index) => context.go(AdminDestination.values[index].route),
        title: context.localized.administration,
        subtitle: Uri.tryParse(serverUrl)?.host ?? serverUrl,
        mark: const AppMark(icon: IconsaxPlusBold.shield_tick),
        exitAction: NavAction(
          icon: IconsaxPlusLinear.arrow_left,
          label: context.localized.backToFiles,
          onTap: () => context.go(AppRoutes.files),
        ),
        child: SearchShortcut(child: child),
      ),
    );
  }
}
