import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/user.dart";
import "package:nomad/providers/admin/admin_users_provider.dart";
import "package:nomad/screens/admin/widgets/user_form_dialog.dart";
import "package:nomad/screens/admin/widgets/user_tile.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/layout/adaptive.dart";
import "package:nomad/widgets/layout/app_page.dart";
import "package:nomad/widgets/shared/async_value_view.dart";
import "package:nomad/widgets/shared/message_view.dart";
import "package:nomad/widgets/shared/nav_group.dart";

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppPage(
    title: Text(context.localized.users),
    body: AsyncValueView<List<User>>(
      value: ref.watch(adminUsersProvider),
      onRetry: () => ref.invalidate(adminUsersProvider),
      data: (users) => users.isEmpty
          ? MessageView(icon: IconsaxPlusLinear.profile_2user, message: context.localized.noUsers)
          : ReadableWidth(
              maxWidth: 840,
              builder: (context, inset) => ListView(
                padding: inset + const EdgeInsets.only(top: 8, bottom: 96),
                children: [
                  NavGroup(
                    title: context.localized.usersCount(users.length),
                    children: [for (final user in users) UserTile(user: user)],
                  ),
                ],
              ),
            ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      icon: const Icon(IconsaxPlusLinear.user_add),
      label: Text(context.localized.addUser),
      onPressed: () => showUserFormDialog(context),
    ),
  );
}
