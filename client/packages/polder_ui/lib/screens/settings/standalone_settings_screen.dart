import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/screens/settings/widgets/sign_out.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/layout/app_page.dart";
import "package:polder_ui/widgets/shared/appearance_settings.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";
import "package:polder_ui/widgets/shared/user_avatar.dart";

class StandaloneSettingsScreen extends ConsumerWidget {
  const StandaloneSettingsScreen({this.groups = const [], super.key});

  final List<Widget> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final localized = context.localized;
    return AppPage(
      title: Text(localized.navSettings),
      body: account == null
          ? const SizedBox.shrink()
          : ReadableWidth(
              maxWidth: 720,
              builder: (context, inset) => ListView(
                padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  NavGroup(
                    title: localized.account,
                    children: [
                      ListTile(
                        leading: UserAvatar(user: account.user, serverUrl: account.serverUrl, size: 40),
                        title: Text(account.user.displayName),
                        subtitle: Text(account.serverUrl),
                        trailing: IconButton(
                          tooltip: localized.signOut,
                          icon: const Icon(IconsaxPlusLinear.logout),
                          onPressed: () => confirmSignOut(context, ref),
                        ),
                      ),
                    ],
                  ),
                  ...groups,
                  NavGroup(
                    title: localized.appearance,
                    children: const [Padding(padding: EdgeInsets.all(20), child: AppearanceSettings())],
                  ),
                ],
              ),
            ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.localized.navSettings,
    icon: const Icon(IconsaxPlusLinear.setting_2),
    onPressed: () => goWithin(context, readPolderUiConfig(context).accountSettings),
  );
}
