import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/trash/widgets/trash_item_tile.dart";
import "package:polder/screens/trash/widgets/trash_summary.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/refreshable_empty_view.dart";

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(trashProvider);
    final notifier = ref.read(trashProvider.notifier);
    final hasItems = trash.value?.items.isNotEmpty ?? false;
    return AppPage(
      title: Text(context.localized.navTrash),
      actions: [
        const TransfersButton(),
        if (hasItems)
          IconButton(
            tooltip: context.localized.emptyTrash,
            icon: const Icon(IconsaxPlusLinear.trash),
            onPressed: () => _confirmEmpty(context, notifier),
          ),
      ],
      body: AsyncValueView<TrashListing>(
        value: trash,
        onRetry: notifier.refresh,
        data: (listing) => ReadableWidth(
          maxWidth: 1200,
          builder: (context, inset) => RefreshIndicator(
            edgeOffset: inset.top,
            onRefresh: notifier.refresh,
            child: listing.items.isEmpty
                ? _EmptyTrash(retention: listing.retention)
                : ListView.builder(
                    padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: listing.items.length + 1,
                    itemBuilder: (context, index) => index == 0
                        ? TrashSummary(listing: listing)
                        : GroupedTile(
                            index: index - 1,
                            count: listing.items.length,
                            child: TrashItemTile(item: listing.items[index - 1]),
                          ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEmpty(BuildContext context, TrashNotifier notifier) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.emptyTrashTitle,
      message: context.localized.emptyTrashMessage,
      confirmLabel: context.localized.emptyTrash,
      destructive: true,
    );
    if (confirmed && context.mounted) await context.runWithFeedback(notifier.empty());
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash({required this.retention});

  final TrashRetention retention;

  @override
  Widget build(BuildContext context) => RefreshableEmptyView(
    child: MessageView(
      icon: IconsaxPlusLinear.trash,
      message: "${context.localized.trashEmpty}\n${retentionHint(context, retention)}",
    ),
  );
}
