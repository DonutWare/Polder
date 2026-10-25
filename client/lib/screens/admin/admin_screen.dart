import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/screens/admin/admin_branding_screen.dart";
import "package:polder/screens/admin/admin_logs_screen.dart";
import "package:polder/screens/admin/admin_overview_screen.dart";
import "package:polder/screens/admin/admin_server_screen.dart";
import "package:polder/screens/admin/admin_users_screen.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";

class AdminScreen extends StatelessWidget {
  const AdminScreen({this.page, super.key});

  final AdminPage? page;

  @override
  Widget build(BuildContext context) => DualPane(
    title: Text(context.localized.administration),
    listLocation: AppRoutes.admin,
    list: _AdminList(selected: DualPane.highlights(context) ? page ?? AdminPage.overview : null),
    placeholder: MessageView(icon: IconsaxPlusLinear.shield_tick, message: context.localized.nothingSelected),
    defaultDetail: _pageFor(AdminPage.overview),
    detail: switch (page) {
      final page? => _pageFor(page),
      null => null,
    },
  );

  static Widget _pageFor(AdminPage page) => switch (page) {
    AdminPage.overview => const AdminOverviewScreen(key: ValueKey(AdminPage.overview)),
    AdminPage.users => const AdminUsersScreen(key: ValueKey(AdminPage.users)),
    AdminPage.branding => const AdminBrandingScreen(key: ValueKey(AdminPage.branding)),
    AdminPage.logs => const AdminLogsScreen(key: ValueKey(AdminPage.logs)),
    AdminPage.server => const AdminServerScreen(key: ValueKey(AdminPage.server)),
  };
}

class _AdminList extends StatelessWidget {
  const _AdminList({required this.selected});

  final AdminPage? selected;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    NavEntry entry(AdminPage page, IconData icon, String title, String subtitle) => NavEntry(
      icon: icon,
      title: title,
      subtitle: subtitle,
      selected: selected == page,
      onTap: () => goWithin(context, AppRoutes.adminPage(page)),
    );
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        NavGroup(
          title: localized.administration,
          children: [
            entry(AdminPage.overview, IconsaxPlusLinear.category, localized.adminOverview, localized.adminOverviewHint),
            entry(AdminPage.users, IconsaxPlusLinear.profile_2user, localized.users, localized.manageUsersHint),
            entry(AdminPage.branding, IconsaxPlusLinear.brush_2, localized.brandingGroup, localized.brandingHint),
            entry(AdminPage.logs, IconsaxPlusLinear.document_text, localized.serverLogs, localized.serverLogsHint),
            entry(
              AdminPage.server,
              IconsaxPlusLinear.setting_4,
              localized.serverSettings,
              localized.serverSettingsHint,
            ),
          ],
        ),
      ],
    );
  }
}
