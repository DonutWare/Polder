import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/providers/current_user_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder_drive/providers/sync/conflict_queue_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/shell/shell_destination_labels.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/navigation/account_sheet.dart";
import "package:polder_ui/widgets/shared/quota_bar.dart";

class MoreOptions extends ConsumerWidget {
  const MoreOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final localized = context.localized;
    final activity = ref.watch(activityBadgeProvider);
    final conflicts = ref.watch(conflictQueueProvider.select((queue) => queue.conflicts.length));

    void open(String location) {
      SideSheetDrawer.of(context).dismiss();
      unawaited(context.push(location));
    }

    return AccountSheet(
      onOpenAccount: (_) => open(AppRoutes.account),
      identityFooter: const QuotaBar(),
      children: [
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
            trailing: switch (destination) {
              ShellDestination.activity when activity != null => Badge(label: Text(activity)),
              ShellDestination.sync when conflicts > 0 => Badge(label: Text("$conflicts")),
              _ => null,
            },
            onTap: () => open(destination.route),
          ),
      ],
    );
  }
}
