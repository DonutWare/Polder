import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/groups/groups_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/screens/groups/widgets/add_member_dialog.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/layout/split_view.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";
import "package:polder/widgets/sharing/share_labels.dart";
import "package:polder/widgets/sharing/share_settings.dart";
import "package:polder/widgets/sharing/share_target_avatar.dart";

enum _GroupAction { rename, leave, delete }

class GroupPage extends ConsumerWidget {
  const GroupPage({required this.groupId, this.scope = GroupScope.mine, super.key});

  final int groupId;
  final GroupScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(groupProvider(groupId));
    final localized = context.localized;
    final me = ref.watch(currentUserProvider).value?.id;
    final group = details.value?.group;
    return AppPage(
      leading: SplitView.backTo(context, AppRoutes.groupsScope(scope: scope)),
      title: Text(group?.name ?? localized.groups),
      actions: [
        if (details.value case final loaded?)
          PopupMenuButton<_GroupAction>(
            icon: const Icon(IconsaxPlusLinear.more),
            onSelected: (action) => switch (action) {
              _GroupAction.rename => _rename(context, ref, loaded.group),
              _GroupAction.leave => _leave(context, ref, loaded, me!),
              _GroupAction.delete => _delete(context, ref, loaded.group),
            },
            itemBuilder: (context) => [
              if (loaded.canManage)
                PopupMenuItem(
                  value: _GroupAction.rename,
                  child: ListTile(leading: const Icon(IconsaxPlusLinear.edit_2), title: Text(localized.renameGroup)),
                ),
              if (me != null && loaded.group.myRole != null)
                PopupMenuItem(
                  value: _GroupAction.leave,
                  child: ListTile(leading: const Icon(IconsaxPlusLinear.logout), title: Text(localized.leaveGroup)),
                ),
              if (loaded.canManage)
                PopupMenuItem(
                  value: _GroupAction.delete,
                  child: ListTile(
                    leading: Icon(IconsaxPlusLinear.trash, color: Theme.of(context).colorScheme.error),
                    title: Text(
                      localized.deleteGroupTitle,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
            ],
          ),
      ],
      body: AsyncValueView<GroupDetails>(
        value: details,
        onRetry: () => ref.invalidate(groupProvider(groupId)),
        data: (details) => ReadableWidth(
          maxWidth: 840,
          builder: (context, inset) => ListView(
            padding: inset + const EdgeInsets.only(top: 8, bottom: 96),
            children: [
              _Summary(details: details),
              NavGroup(
                title: localized.groupMembers,
                trailing: details.canManage
                    ? TextButton.icon(
                        icon: const Icon(IconsaxPlusLinear.user_add, size: 18),
                        label: Text(localized.addMember),
                        onPressed: () => showAddMemberDialog(context, details),
                      )
                    : null,
                children: [
                  for (final member in details.members)
                    _MemberTile(details: details, member: member, isMe: member.user.id == me),
                ],
              ),
              _GroupShares(groupId: groupId),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Group group) async {
    final name = await showTextInputDialog(
      context,
      title: context.localized.renameGroup,
      label: context.localized.groupName,
      confirmLabel: context.localized.save,
      initialValue: group.name,
    );
    if (name == null || name.trim() == group.name || !context.mounted) return;
    await context.runWithFeedback(ref.read(groupProvider(groupId).notifier).rename(name.trim()));
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, GroupDetails details, int me) async {
    final localized = context.localized;
    final group = details.group;
    final alone = details.members.length == 1;
    if (!alone && group.myRole == GroupRole.admin && details.adminCount == 1) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(localized.leaveGroupTitle(group.name)),
          content: Text(localized.leaveGroupLastAdminMessage(group.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: alone ? localized.deleteGroupTitle : localized.leaveGroupTitle(group.name),
      message: alone ? localized.leaveGroupAloneMessage(group.name) : localized.leaveGroupMessage,
      confirmLabel: alone ? localized.leaveAndDeleteGroup : localized.leaveGroup,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final left = await context.runWithFeedback(ref.read(groupProvider(groupId).notifier).leave(me));
    if (left && context.mounted) context.go(AppRoutes.groupsScope(scope: scope));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Group group) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.deleteGroupTitle,
      message: context.localized.deleteGroupMessage(group.name),
      confirmLabel: context.localized.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final deleted = await context.runWithFeedback(ref.read(groupProvider(groupId).notifier).delete());
    if (deleted && context.mounted) context.go(AppRoutes.groupsScope(scope: scope));
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.details});

  final GroupDetails details;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final group = details.group;
    final role = group.myRole;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(
        [
          localized.shareGroupMembers(group.memberCount),
          if (role != null) role.label(localized),
          if (group.createdBy case final creator?) localized.groupCreatedBy(creator.name),
        ].join(" · "),
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.details, required this.member, required this.isMe});

  final GroupDetails details;
  final GroupMember member;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(groupProvider(details.group.id).notifier);
    final lastAdmin = member.role == GroupRole.admin && details.adminCount <= 1;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      leading: ShareTargetAvatar(target: member.user),
      title: Text(member.user.name, overflow: TextOverflow.ellipsis),
      trailing: details.canManage
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<GroupRole>(
                  value: member.role,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final role in GroupRole.values)
                      DropdownMenuItem(
                        value: role,
                        enabled: !lastAdmin || role == GroupRole.admin,
                        child: Tooltip(message: role.hint(localized), child: Text(role.label(localized))),
                      ),
                  ],
                  onChanged: (role) {
                    if (role != null && role != member.role) context.runWithFeedback(notifier.setRole(member, role));
                  },
                ),
                if (!isMe && !lastAdmin)
                  IconButton(
                    tooltip: localized.removeMember,
                    icon: Icon(IconsaxPlusLinear.minus_cirlce, color: Theme.of(context).colorScheme.error),
                    onPressed: () => context.runWithFeedback(notifier.removeMember(member)),
                  ),
              ],
            )
          : Text(member.role.label(localized), style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _GroupShares extends ConsumerWidget {
  const _GroupShares({required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return NavGroup(
      title: localized.groupShared,
      children: switch (ref.watch(groupSharesProvider(groupId))) {
        AsyncValue(hasValue: true, :final value?) when value.isNotEmpty => [
          for (final share in value) _GroupShareTile(share: share),
        ],
        AsyncValue(hasValue: true) => [ListTile(title: Text(localized.noGroupShares))],
        AsyncError(:final error) => [
          ListTile(
            title: Text(context.describeError(error)),
            trailing: TextButton(
              onPressed: () => ref.invalidate(groupSharesProvider(groupId)),
              child: Text(localized.retry),
            ),
          ),
        ],
        _ => [const ListTile(title: LinearProgressIndicator())],
      },
    );
  }
}

class _GroupShareTile extends StatelessWidget {
  const _GroupShareTile({required this.share});

  final OutgoingShare share;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final editable = share.isManageable;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      leading: FileTypeIcon.of(isDir: share.file.isDir, mime: "", size: 36),
      title: Text(share.file.displayName(localized), overflow: TextOverflow.ellipsis),
      subtitle: Text(
        localized.sharedByWithPermission(share.owner.name, share.permissions.summary(localized)),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: editable ? const Icon(IconsaxPlusLinear.setting_4) : null,
      onTap: editable ? () => showShareSettings(context, share) : null,
    );
  }
}
