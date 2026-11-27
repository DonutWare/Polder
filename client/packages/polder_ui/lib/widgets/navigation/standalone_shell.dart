import "package:flutter/material.dart";

import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/navigation/account_sheet.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";

class StandaloneShell extends StatelessWidget {
  const StandaloneShell({
    required this.title,
    required this.location,
    required this.child,
    this.sidebar,
    this.rail,
    this.railFooter,
    this.sheetItems,
    this.sheetFooter,
    this.sidebarWidth = 300,
    super.key,
  });

  final String title;
  final Uri location;
  final Widget? sidebar;
  final Widget? rail;
  final Widget? railFooter;
  final Widget? sheetItems;
  final Widget? sheetFooter;
  final double sidebarWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final phone = AdaptiveLayout.isPhone(context);
    final items = sheetItems;
    return SideSheetDrawer(
      title: title,
      sheet: AccountSheet(
        identityFooter: sheetFooter,
        children: [
          if (phone && items != null) ...[
            items,
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
          ],
          const AccountSettingsTile(),
        ],
      ),
      canEdgeSwipe: () => phone && readPolderUiConfig(context).isTopLevel(location.toString()),
      child: NavigationShell(
        showNavigation: !phone,
        items: const [],
        selectedIndex: -1,
        onSelected: (_) {},
        sidebarWidth: sidebarWidth,
        sidebar: sidebar,
        rail: rail,
        railFooter: railFooter,
        canExpand: sidebar != null,
        child: child,
      ),
    );
  }
}
