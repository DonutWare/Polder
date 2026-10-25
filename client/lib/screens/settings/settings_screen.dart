import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/screens/settings/about_screen.dart";
import "package:polder/screens/settings/account_screen.dart";
import "package:polder/screens/settings/general_settings_screen.dart";
import "package:polder/screens/settings/widgets/account_tile.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({this.page, super.key});

  final SettingsPage? page;

  @override
  Widget build(BuildContext context) => DualPane(
    title: Text(context.localized.navSettings),
    listLocation: AppRoutes.settings,
    list: _SettingsList(selected: DualPane.highlights(context) ? page ?? SettingsPage.general : null),
    placeholder: MessageView(icon: IconsaxPlusLinear.setting_2, message: context.localized.nothingSelected),
    defaultDetail: _pageFor(SettingsPage.general),
    detail: switch (page) {
      final page? => _pageFor(page),
      null => null,
    },
  );

  static Widget _pageFor(SettingsPage page) => switch (page) {
    SettingsPage.general => const GeneralSettingsScreen(key: ValueKey(SettingsPage.general)),
    SettingsPage.account => const AccountScreen(key: ValueKey(SettingsPage.account)),
    SettingsPage.about => const AboutScreen(key: ValueKey(SettingsPage.about)),
  };
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({required this.selected});

  final SettingsPage? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final localized = context.localized;
    void open(SettingsPage page) => goWithin(context, AppRoutes.settingsPage(page));
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        if (account != null)
          NavGroup(
            title: localized.account,
            children: [
              AccountTile(
                account: account,
                selected: selected == SettingsPage.account,
                onTap: () => open(SettingsPage.account),
              ),
            ],
          ),
        NavGroup(
          title: localized.navSettings,
          children: [
            NavEntry(
              icon: IconsaxPlusLinear.setting_2,
              title: localized.generalSettings,
              subtitle: localized.generalSettingsHint,
              selected: selected == SettingsPage.general,
              onTap: () => open(SettingsPage.general),
            ),
            NavEntry(
              icon: IconsaxPlusLinear.info_circle,
              title: localized.about,
              subtitle: localized.aboutHint,
              selected: selected == SettingsPage.about,
              onTap: () => open(SettingsPage.about),
            ),
          ],
        ),
        if (isAdmin)
          NavGroup(
            title: localized.administration,
            children: [
              NavEntry(
                icon: IconsaxPlusLinear.shield_tick,
                iconColor: AppColors.of(context).warning,
                title: localized.administration,
                subtitle: localized.administrationHint,
                onTap: () => context.push(AppRoutes.admin),
              ),
            ],
          ),
      ],
    );
  }
}
