import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/screens/settings/widgets/sign_out.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/shared/connection_status.dart";
import "package:polder_ui/widgets/shared/user_avatar.dart";

class AccountSheet extends ConsumerWidget {
  const AccountSheet({
    this.onOpenAccount,
    this.identityFooter,
    this.children = const [AccountSettingsTile()],
    super.key,
  });

  final ValueChanged<BuildContext>? onOpenAccount;
  final Widget? identityFooter;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final cs = Theme.of(context).colorScheme;
    final footer = identityFooter;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          padding: EdgeInsets.only(bottom: footer == null ? 0 : 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(color: AppColors.of(context).inset, shape: squircle(AppRadius.inset + 4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => (onOpenAccount ?? openAccountSettings)(context),
                  child: const Padding(padding: EdgeInsets.all(16), child: AccountIdentity(avatarSize: 44)),
                ),
              ),
              if (footer != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: footer),
            ],
          ),
        ),
        const ConnectionStatusTile(),
        const SizedBox(height: 4),
        ...children,
        if (account != null) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
          ListTile(
            leading: Icon(IconsaxPlusLinear.logout, color: cs.error),
            title: Text(context.localized.signOut, style: TextStyle(color: cs.error)),
            onTap: () {
              final drawer = SideSheetDrawer.of(context);
              unawaited(confirmSignOut(context, ref, onConfirmed: drawer.close));
            },
          ),
        ],
      ],
    );
  }
}

void openAccountSettings(BuildContext context) {
  SideSheetDrawer.of(context).dismiss();
  goWithin(context, readPolderUiConfig(context).accountSettings);
}

class AccountSettingsTile extends StatelessWidget {
  const AccountSettingsTile({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(IconsaxPlusLinear.setting_2),
    title: Text(context.localized.navSettings),
    onTap: () => openAccountSettings(context),
  );
}
