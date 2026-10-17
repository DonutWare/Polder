import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/groups/groups_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/sharing/share_labels.dart";
import "package:polder/widgets/sharing/share_target_avatar.dart";

Future<void> showAddMemberDialog(BuildContext context, GroupDetails details) => showDialog<void>(
  context: context,
  builder: (_) => _AddMemberDialog(details: details),
);

class _AddMemberDialog extends ConsumerStatefulWidget {
  const _AddMemberDialog({required this.details});

  final GroupDetails details;

  @override
  ConsumerState<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<_AddMemberDialog> {
  var _query = "";
  var _role = GroupRole.member;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final members = {for (final member in widget.details.members) member.user.id};
    return AlertDialog(
      title: Text(localized.addMember),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            SegmentedButton<GroupRole>(
              segments: [
                for (final role in GroupRole.values)
                  ButtonSegment(value: role, label: Text(role.label(localized)), tooltip: role.hint(localized)),
              ],
              selected: {_role},
              onSelectionChanged: (selection) => setState(() => _role = selection.first),
            ),
            Text(_role.hint(localized), style: Theme.of(context).textTheme.bodySmall),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1),
                hintText: localized.filterUsers,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            Expanded(
              child: AsyncValueView<ShareTargets>(
                value: ref.watch(shareTargetSearchProvider(_query)),
                data: (found) {
                  final users = found.users.where((user) => !members.contains(user.id)).toList();
                  if (users.isEmpty) return Center(child: Text(localized.shareNoMatches));
                  return ListView(
                    children: [
                      for (final user in users)
                        ListTile(
                          leading: ShareTargetAvatar(target: user),
                          title: Text(user.name, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(IconsaxPlusLinear.add),
                          onTap: () => _add(user),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.done))],
    );
  }

  Future<void> _add(ShareTarget user) async {
    final added = await context.runWithFeedback(
      ref.read(groupProvider(widget.details.group.id).notifier).addMember(user, _role),
    );
    if (added && mounted) Navigator.pop(context);
  }
}
