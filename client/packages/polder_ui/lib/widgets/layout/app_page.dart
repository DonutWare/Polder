import "package:material_ui/material_ui.dart";

import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/layout/dual_pane.dart";
import "package:polder_ui/widgets/shared/app_bar_fade.dart";

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
    final config = readPolderUiConfig(context);
    final menuButton = config.menuButton;
    final stacked = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    final inDetail = DualPane.isDetail(context);
    final isRoot = !stacked || inDetail || PageStack.contains(context);
    final inShell = SideSheetDrawer.maybeOf(context) != null;
    final location = UpScope.locationOf(context);
    final onTab = location == null || config.isTopLevel(location);
    final firstPage = leading == null && !stacked && !inDetail;
    final showMenu = menuButton != null && firstPage && onTab && inShell && AdaptiveLayout.isPhone(context);
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
        leading: leading ?? (showMenu ? menuButton : (showUp ? const UpButton() : null)),
        titleSpacing: showMenu || showUp || leading != null ? 4 : null,
        title: title,
        actions: [if (isRoot) ...config.pageActions, ...?actions, const SizedBox(width: 8)],
        bottom: bottom,
      ),
      body: body,
    );
  }
}
