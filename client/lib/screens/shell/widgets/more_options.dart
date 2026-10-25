import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/settings/widgets/sign_out.dart";
import "package:polder/screens/shell/shell_destination_labels.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/quota_bar.dart";
import "package:polder/widgets/shared/user_avatar.dart";

/// The side sheet behind the menu button: who is signed in, the pages that open on top of the shell, and
/// the way into administration.
class MoreOptions extends ConsumerWidget {
  const MoreOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final colors = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final localized = context.localized;

    final activity = ref.watch(activityBadgeProvider);

    void open(String location) {
      SideSheetDrawer.of(context).dismiss();
      unawaited(context.push(location));
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
                  onTap: () => open(AppRoutes.account),
                  child: const Padding(padding: EdgeInsets.all(16), child: AccountIdentity(avatarSize: 44)),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: QuotaBar()),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (isAdmin)
          ListTile(
            leading: const Icon(IconsaxPlusLinear.shield_tick),
            title: Text(localized.administration),
            subtitle: Text(localized.administrationHint),
            onTap: () => open(AppRoutes.admin),
          ),
        ListTile(
          leading: const Icon(IconsaxPlusLinear.user_edit),
          title: Text(localized.account),
          subtitle: Text(localized.accountSettingsHint),
          onTap: () => open(AppRoutes.account),
        ),
        for (final destination in ref.watch(stackedDestinationsProvider))
          ListTile(
            leading: Icon(destination.icon),
            title: Text(destination.label(context)),
            trailing: destination == ShellDestination.activity && activity != null
                ? Badge(label: Text(activity))
                : null,
            onTap: () => open(destination.route),
          ),
        if (account != null) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
          ListTile(
            leading: Icon(IconsaxPlusLinear.logout, color: cs.error),
            title: Text(localized.signOut, style: TextStyle(color: cs.error)),
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
