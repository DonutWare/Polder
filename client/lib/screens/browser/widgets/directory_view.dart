import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/file_grid_view.dart";
import "package:polder/screens/browser/widgets/file_list_view.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/message_view.dart";

class DirectoryView extends ConsumerWidget {
  const DirectoryView({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(directoryProvider(path).notifier);
    final pending = ref.watch(pendingUploadsProvider(path));
    final busyFolders = ref.watch(busyFoldersProvider(path));
    return AsyncValueView<DirectoryListing>(
      value: ref.watch(directoryProvider(path)),
      onRetry: notifier.refresh,
      data: (listing) {
        final items = mergePendingUploads(
          ref.watch(browserSortProvider).apply(listing.entries),
          pending,
          busyFolders: busyFolders,
        );
        return ReadableWidth(
          maxWidth: 1200,
          builder: (context, inset) => RefreshIndicator(
            edgeOffset: inset.top,
            onRefresh: notifier.refresh,
            child: items.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: MessageView(icon: IconsaxPlusLinear.folder_open, message: context.localized.emptyFolder),
                      ),
                    ),
                  )
                : _EntriesView(path: path, items: items, padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96)),
          ),
        );
      },
    );
  }
}

class _EntriesView extends ConsumerWidget {
  const _EntriesView({required this.path, required this.items, required this.padding});

  final String path;
  final List<BrowserItem> items;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(browserViewModeProvider)) {
    BrowserViewMode.list => FileListView(parentPath: path, items: items, padding: padding),
    BrowserViewMode.grid => FileGridView(parentPath: path, items: items, padding: padding),
  };
}
