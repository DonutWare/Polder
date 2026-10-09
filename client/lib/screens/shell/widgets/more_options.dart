import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/shell/shell_destination_labels.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/quota_bar.dart";
import "package:polder/widgets/shared/user_avatar.dart";

/// The side sheet behind the menu button: who is signed in, their account settings, and the way into
/// (or out of) administration.
class MoreOptions extends ConsumerWidget {
  const MoreOptions({this.inAdministration = false, super.key});

  final bool inAdministration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final colors = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final localized = context.localized;

    void go(String location) {
      SideSheetDrawer.of(context).close();
      context.go(location);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          padding: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(color: colors.inset, shape: squircle(AppRadius.inset + 4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => go(AppRoutes.account),
                  child: const Padding(padding: EdgeInsets.all(16), child: AccountIdentity(avatarSize: 44)),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: QuotaBar()),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (inAdministration)
          ListTile(
            leading: const Icon(IconsaxPlusLinear.folder_2),
            title: Text(localized.backToFiles),
            onTap: () => go(AppRoutes.files),
          )
        else if (isAdmin)
          ListTile(
            leading: const Icon(IconsaxPlusLinear.shield_tick),
            title: Text(localized.administration),
            subtitle: Text(localized.administrationHint),
            onTap: () => go(AppRoutes.admin),
          ),
        ListTile(
          leading: const Icon(IconsaxPlusLinear.user_edit),
          title: Text(localized.account),
          subtitle: Text(localized.accountSettingsHint),
          onTap: () => go(AppRoutes.account),
        ),
        if (!inAdministration)
          for (final destination in ref.watch(secondaryShellDestinationsProvider))
            ListTile(
              leading: Icon(destination.icon),
              title: Text(destination.label(context)),
              onTap: () => go(destination.route),
            ),
        if (account != null) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
          ListTile(
            leading: Icon(IconsaxPlusLinear.logout, color: cs.error),
            title: Text(localized.signOut, style: TextStyle(color: cs.error)),
            onTap: () => _signOut(context, ref, account.user.username, account.serverUrl),
          ),
        ],
      ],
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref, String username, String serverUrl) async {
    final notifier = ref.read(accountProvider.notifier);
    final drawer = SideSheetDrawer.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.signOut,
      message: context.localized.signOutMessage(username, serverUrl),
      confirmLabel: context.localized.signOut,
    );
    if (!confirmed) return;
    drawer.close();
    await notifier.signOut();
  }
}
