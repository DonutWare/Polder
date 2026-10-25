import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/admin/admin_users_provider.dart";
import "package:polder/screens/admin/widgets/admin_stats_grid.dart";
import "package:polder/screens/admin/widgets/storage_by_user_card.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return AppPage(
      title: Text(localized.adminOverview),
      actions: [
        IconButton(
          tooltip: localized.refresh,
          icon: const Icon(IconsaxPlusLinear.refresh),
          onPressed: () => ref.invalidate(adminUsersProvider),
        ),
      ],
      body: AsyncValueView<List<User>>(
        value: ref.watch(adminUsersProvider),
        onRetry: () => ref.invalidate(adminUsersProvider),
        data: (users) => ReadableWidth(
          maxWidth: 1080,
          builder: (context, inset) => RefreshIndicator(
            edgeOffset: inset.top,
            onRefresh: () => ref.refresh(adminUsersProvider.future),
            child: ListView(
              padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: AdminStatsGrid(users: users),
                ),
                const SizedBox(height: 8),
                StorageByUserCard(users: users),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
