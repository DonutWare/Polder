import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/user.dart";
import "package:polder/providers/admin/admin_users_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/screens/admin/widgets/user_form_dialog.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/level_bar.dart";
import "package:polder/widgets/shared/tag.dart";

enum _UserAction { edit, delete }

class UserTile extends ConsumerWidget {
  const UserTile({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelf = ref.watch(currentUserProvider).value?.id == user.id;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final localized = context.localized;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: IconBadge(
        icon: user.isAdmin ? IconsaxPlusLinear.shield_tick : IconsaxPlusLinear.user,
        color: user.disabled ? theme.colorScheme.outline : (user.isAdmin ? colors.warning : null),
      ),
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(user.username, overflow: TextOverflow.ellipsis)),
          if (user.isAdmin) Tag(text: localized.roleAdmin, color: colors.warning),
          if (user.disabled) Tag(text: localized.disabled, color: theme.colorScheme.error),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text(_quota(context)),
          if (user.hasQuota) LevelBar(fraction: user.usedFraction, height: 4),
        ],
      ),
      onTap: () => showUserFormDialog(context, user: user),
      trailing: PopupMenuButton<_UserAction>(
        icon: const Icon(IconsaxPlusLinear.more),
        onSelected: (action) => switch (action) {
          _UserAction.edit => showUserFormDialog(context, user: user),
          _UserAction.delete => _confirmDelete(context, ref),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _UserAction.edit,
            child: ListTile(leading: const Icon(IconsaxPlusLinear.edit_2), title: Text(localized.edit)),
          ),
          if (!isSelf)
            PopupMenuItem(
              value: _UserAction.delete,
              child: ListTile(
                leading: Icon(IconsaxPlusLinear.trash, color: theme.colorScheme.error),
                title: Text(localized.delete, style: TextStyle(color: theme.colorScheme.error)),
              ),
            ),
        ],
      ),
    );
  }

  String _quota(BuildContext context) {
    final used = ByteFormat.format(user.usedBytes, locale: context.localeName);
    return user.hasQuota
        ? context.localized.quotaUsedOf(used, ByteFormat.format(user.quotaBytes, locale: context.localeName))
        : context.localized.quotaUsedUnlimited(used);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.deleteUserTitle(user.username),
      message: context.localized.deleteUserMessage,
      confirmLabel: context.localized.delete,
      destructive: true,
    );
    if (confirmed && context.mounted) await context.runWithFeedback(ref.read(adminUsersProvider.notifier).delete(user));
  }
}
