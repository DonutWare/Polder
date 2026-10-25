import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/account.dart";
import "package:polder/screens/settings/widgets/sign_out.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/user_avatar.dart";

class AccountTile extends ConsumerWidget {
  const AccountTile({required this.account, required this.onTap, this.selected = false, super.key});

  final Account account;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.secondaryContainer.withAlpha(175) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
          child: AccountIdentity(
            avatarSize: 44,
            trailing: IconButton(
              tooltip: context.localized.signOut,
              icon: Icon(IconsaxPlusLinear.logout, color: cs.error),
              onPressed: () => confirmSignOut(context, ref),
            ),
          ),
        ),
      ),
    );
  }
}
