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
    required this.sidebar,
    required this.rail,
    required this.child,
    this.sheet = const AccountSheet(),
    this.sidebarWidth = 300,
    super.key,
  });

  final String title;
  final Uri location;
  final Widget sidebar;
  final Widget rail;
  final Widget sheet;
  final double sidebarWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final phone = AdaptiveLayout.isPhone(context);
    return SideSheetDrawer(
      title: title,
      sheet: sheet,
      canEdgeSwipe: () => phone && readPolderUiConfig(context).isTopLevel(location.toString()),
      child: NavigationShell(
        showNavigation: !phone,
        items: const [],
        selectedIndex: -1,
        onSelected: (_) {},
        sidebarWidth: sidebarWidth,
        sidebar: sidebar,
        rail: rail,
        child: child,
      ),
    );
  }
}
