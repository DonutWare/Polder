import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/models/user.dart";
import "package:nomad/providers/activity/activity_scope_provider.dart";
import "package:nomad/providers/admin/admin_users_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/async_value_view.dart";

enum _ScopeChoice { me, all, user }

class ActivityScopeButton extends ConsumerWidget {
  const ActivityScopeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(activityScopeProvider);
    final localized = context.localized;
    return PopupMenuButton<_ScopeChoice>(
      tooltip: localized.activityScopeTooltip,
      icon: const Icon(IconsaxPlusLinear.profile_2user),
      onSelected: (choice) async {
        final notifier = ref.read(activityScopeProvider.notifier);
        switch (choice) {
          case _ScopeChoice.me:
            notifier.select(const ActivityScope.me());
          case _ScopeChoice.all:
            notifier.select(const ActivityScope.all());
          case _ScopeChoice.user:
            final user = await showDialog<User>(context: context, builder: (_) => const _UserPickerDialog());
            if (user != null) notifier.select(ActivityScope.user(id: user.id, username: user.username));
        }
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: _ScopeChoice.me,
          checked: scope is ActivityScopeMe,
          child: Text(localized.activityScopeMe),
        ),
        CheckedPopupMenuItem(
          value: _ScopeChoice.all,
          checked: scope is ActivityScopeAll,
          child: Text(localized.activityScopeAll),
        ),
        CheckedPopupMenuItem(
          value: _ScopeChoice.user,
          checked: scope is ActivityScopeUser,
          child: Text(scope is ActivityScopeUser ? scope.username : localized.activityScopeChooseUser),
        ),
      ],
    );
  }
}

class _UserPickerDialog extends ConsumerWidget {
  const _UserPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: Text(context.localized.chooseUserTitle),
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    content: SizedBox(
      width: 360,
      child: AsyncValueView<List<User>>(
        value: ref.watch(adminUsersProvider),
        data: (users) => ListView(
          shrinkWrap: true,
          children: [
            for (final user in users)
              ListTile(
                leading: const Icon(IconsaxPlusLinear.user),
                title: Text(user.username),
                onTap: () => Navigator.of(context).pop(user),
              ),
          ],
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.localized.cancel))],
  );
}
