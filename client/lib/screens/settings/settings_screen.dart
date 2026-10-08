import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/settings/widgets/account_tile.dart";
import "package:polder/screens/settings/widgets/trash_settings_group.dart";
import "package:polder/screens/settings/widgets/version_settings_group.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/appearance_settings.dart";
import "package:polder/widgets/shared/nav_group.dart";

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final localized = context.localized;
    return AppPage(
      title: Text(localized.navSettings),
      body: ReadableWidth(
        maxWidth: 720,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            if (account != null)
              NavGroup(
                title: localized.account,
                children: [AccountTile(account: account)],
              ),
            const TrashSettingsGroup(),
            const VersionSettingsGroup(),
            NavGroup(
              title: localized.appearance,
              children: const [Padding(padding: EdgeInsets.all(20), child: AppearanceSettings())],
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
                    onTap: () => context.go(AppRoutes.admin),
                  ),
                ],
              ),
            NavGroup(
              title: localized.about,
              children: [
                NavEntry(
                  icon: IconsaxPlusLinear.info_circle,
                  title: localized.about,
                  subtitle: localized.aboutHint,
                  onTap: () => context.go(AppRoutes.about),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
