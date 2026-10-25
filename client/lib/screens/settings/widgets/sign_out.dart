import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";

Future<void> confirmSignOut(BuildContext context, WidgetRef ref, {VoidCallback? onConfirmed}) async {
  final account = ref.read(currentAccountProvider);
  if (account == null) return;
  final notifier = ref.read(accountProvider.notifier);
  final confirmed = await showConfirmDialog(
    context,
    title: context.localized.signOut,
    message: context.localized.signOutMessage(account.user.username, account.serverUrl),
    confirmLabel: context.localized.signOut,
  );
  if (!confirmed) return;
  onConfirmed?.call();
  await notifier.signOut();
}
