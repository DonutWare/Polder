import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/account.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/user_avatar.dart";

class AccountTile extends ConsumerWidget {
  const AccountTile({required this.account, super.key});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go(AppRoutes.account),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
        child: AccountIdentity(
          avatarSize: 44,
          trailing: IconButton(
            tooltip: context.localized.signOut,
            icon: Icon(IconsaxPlusLinear.logout, color: cs.error),
            onPressed: () => _confirmSignOut(context, ref.read(accountProvider.notifier)),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AccountNotifier notifier) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.signOut,
      message: context.localized.signOutMessage(account.user.username, account.serverUrl),
      confirmLabel: context.localized.signOut,
    );
    if (confirmed) await notifier.signOut();
  }
}
