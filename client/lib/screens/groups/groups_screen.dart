import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/group.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/groups/groups_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/screens/groups/group_page.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({this.scope = GroupScope.mine, this.groupId, super.key});

  final GroupScope scope;
  final int? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final selected = groupId;
    final isAdmin = ref.watch(isAdminProvider);
    final shownScope = isAdmin ? scope : GroupScope.mine;
    return DualPane(
      title: isAdmin ? _ScopeMenu(scope: shownScope) : Text(localized.groups),
      listLocation: AppRoutes.groupsScope(scope: shownScope),
      listActions: [
        IconButton(
          tooltip: localized.newGroup,
          icon: const Icon(IconsaxPlusLinear.add_square),
          onPressed: () => _create(context, ref),
        ),
      ],
      list: _GroupList(scope: shownScope, selected: DualPane.highlights(context) ? selected : null),
      placeholder: MessageView(icon: IconsaxPlusLinear.people, message: localized.selectGroup),
      detail: selected == null ? null : GroupPage(key: ValueKey(selected), groupId: selected, scope: shownScope),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await showTextInputDialog(
      context,
      title: context.localized.newGroup,
      label: context.localized.groupName,
      confirmLabel: context.localized.create,
    );
    if (name == null || !context.mounted) return;
    Group? created;
    final ok = await context.runWithFeedback(() async {
      created = await ref.read(groupsProvider(GroupScope.mine).notifier).create(name.trim());
    }());
    if (ok && created != null && context.mounted) goWithin(context, AppRoutes.groupAt(created!.id));
  }
}

class _GroupList extends ConsumerWidget {
  const _GroupList({required this.scope, required this.selected});

  final GroupScope scope;
  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        AsyncValueView<List<Group>>(
          value: ref.watch(groupsProvider(scope)),
          onRetry: () => ref.invalidate(groupsProvider(scope)),
          data: (groups) => groups.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  child: Text(localized.noGroups, style: Theme.of(context).textTheme.bodySmall),
                )
              : Column(
                  children: [
                    for (final group in groups)
                      SidebarItem(
                        icon: IconsaxPlusLinear.people,
                        label: group.name,
                        selected: group.id == selected,
                        detail: localized.shareGroupMembers(group.memberCount),
                        onTap: () => goWithin(context, AppRoutes.groupAt(group.id, scope: scope)),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ScopeMenu extends StatelessWidget {
  const _ScopeMenu({required this.scope});

  final GroupScope scope;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: PopupMenuButton<GroupScope>(
        initialValue: scope,
        tooltip: localized.groups,
        position: PopupMenuPosition.under,
        onSelected: (chosen) => goWithin(context, AppRoutes.groupsScope(scope: chosen)),
        itemBuilder: (context) => [
          for (final option in GroupScope.values)
            CheckedPopupMenuItem(value: option, checked: option == scope, child: Text(_label(localized, option))),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Flexible(child: Text(_label(localized, scope), overflow: TextOverflow.ellipsis)),
              const Icon(IconsaxPlusLinear.arrow_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  static String _label(AppLocalizations localized, GroupScope scope) => switch (scope) {
    GroupScope.mine => localized.myGroups,
    GroupScope.all => localized.allGroups,
  };
}
