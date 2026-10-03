import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/account.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/confirm_dialog.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

class AccountTile extends ConsumerWidget {
  const AccountTile({required this.account, super.key});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const IconBadge(icon: IconsaxPlusLinear.user),
      title: Text(account.user.username),
      subtitle: Text(account.serverUrl, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: context.localized.signOut,
        icon: Icon(IconsaxPlusLinear.logout, color: cs.error),
        onPressed: () => _confirmSignOut(context, ref.read(accountProvider.notifier)),
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
