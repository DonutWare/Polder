import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_core/models/user.dart";
import "package:polder/providers/admin/admin_users_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder/screens/admin/widgets/user_form_dialog.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/action_feedback.dart";
import "package:polder_ui/util/byte_format.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/shared/icon_badge.dart";
import "package:polder_ui/widgets/shared/level_bar.dart";
import "package:polder_ui/widgets/shared/tag.dart";

enum _UserAction { edit, resetTwoFactor, extendTwoFactor, delete }

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
          if (user.twoFactorEnabled) Tag(text: localized.twoFactorTag, color: theme.colorScheme.primary),
          if (user.twoFactorSetupRequired)
            Tag(text: localized.twoFactorOverdueTag, color: theme.colorScheme.error)
          else if (user.twoFactorDue)
            Tag(text: localized.twoFactorDueTag(_date(context, user.twoFactorDeadline!)), color: colors.warning),
          if (user.sso) Tag(text: localized.ssoTag, color: theme.colorScheme.tertiary),
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
          _UserAction.resetTwoFactor => _confirmResetTwoFactor(context, ref),
          _UserAction.extendTwoFactor => context.runWithFeedback(
            ref.read(adminUsersProvider.notifier).extendTwoFactor(user),
          ),
          _UserAction.delete => _confirmDelete(context, ref),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _UserAction.edit,
            child: ListTile(leading: const Icon(IconsaxPlusLinear.edit_2), title: Text(localized.edit)),
          ),
          if (user.twoFactorEnabled && !isSelf)
            PopupMenuItem(
              value: _UserAction.resetTwoFactor,
              child: ListTile(
                leading: const Icon(IconsaxPlusLinear.shield_slash),
                title: Text(localized.resetTwoFactor),
              ),
            ),
          if (user.twoFactorDue)
            PopupMenuItem(
              value: _UserAction.extendTwoFactor,
              child: ListTile(
                leading: const Icon(IconsaxPlusLinear.timer_1),
                title: Text(localized.extendTwoFactorDeadline),
              ),
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

  String _date(BuildContext context, DateTime date) => DateFormat.yMMMd(context.localeName).format(date.toLocal());

  Future<void> _confirmResetTwoFactor(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.resetTwoFactorTitle(user.username),
      message: context.localized.resetTwoFactorMessage,
      confirmLabel: context.localized.resetTwoFactor,
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await context.runWithFeedback(ref.read(adminUsersProvider.notifier).resetTwoFactor(user));
    }
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
