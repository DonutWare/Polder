import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/shared/app_bar_fade.dart";

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final stacked = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    final inDetail = DualPane.isDetail(context);
    final isRoot = !stacked || inDetail || PageStack.contains(context);
    final inShell = SideSheetDrawer.maybeOf(context) != null;
    final location = UpScope.locationOf(context);
    final onTab = location == null || AppRoutes.isTab(location);
    final firstPage = leading == null && !stacked && !inDetail;
    final showMenu = firstPage && onTab && inShell && AdaptiveLayout.isPhone(context);
    final showUp = firstPage && !onTab && UpScope.isActive(context);
    final navigationBarOverlap = MediaQuery.paddingOf(context).bottom - MediaQuery.viewPaddingOf(context).bottom;
    final fab = floatingActionButton;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: fab != null
          ? Padding(
              padding: EdgeInsets.only(bottom: navigationBarOverlap.clamp(0, double.infinity)),
              child: fab,
            )
          : null,
      appBar: AppBar(
        flexibleSpace: const AppBarFade(),
        automaticallyImplyLeading: !inDetail,
        toolbarHeight: isRoot ? 64 : null,
        leading: leading ?? (showMenu ? const MoreOptionsButton() : (showUp ? const UpButton() : null)),
        titleSpacing: showMenu || showUp || leading != null ? 4 : null,
        title: title,
        actions: [if (isRoot) const SearchButton(), ...?actions, const SizedBox(width: 8)],
        bottom: bottom,
      ),
      body: body,
    );
  }
}

class MoreOptionsButton extends ConsumerWidget {
  const MoreOptionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploading = ref.watch(activityBadgeProvider) != null;
    return IconButton(
      tooltip: context.localized.moreOptions,
      icon: Badge(isLabelVisible: uploading, child: const Icon(IconsaxPlusLinear.menu)),
      onPressed: () => SideSheetDrawer.of(context).open(),
    );
  }
}
