import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/directory_listing.dart";
import "package:nomad/providers/browser/browser_view_provider.dart";
import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/screens/browser/widgets/file_grid_view.dart";
import "package:nomad/screens/browser/widgets/file_list_view.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/layout/adaptive.dart";
import "package:nomad/widgets/shared/async_value_view.dart";
import "package:nomad/widgets/shared/message_view.dart";

class DirectoryView extends ConsumerWidget {
  const DirectoryView({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(directoryProvider(path).notifier);
    return AsyncValueView<DirectoryListing>(
      value: ref.watch(directoryProvider(path)),
      onRetry: notifier.refresh,
      data: (listing) => ReadableWidth(
        maxWidth: 1200,
        builder: (context, inset) => RefreshIndicator(
          edgeOffset: inset.top,
          onRefresh: notifier.refresh,
          child: listing.entries.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: MessageView(icon: IconsaxPlusLinear.folder_open, message: context.localized.emptyFolder),
                    ),
                  ),
                )
              : _EntriesView(path: path, listing: listing, padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96)),
        ),
      ),
    );
  }
}

class _EntriesView extends ConsumerWidget {
  const _EntriesView({required this.path, required this.listing, required this.padding});

  final String path;
  final DirectoryListing listing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(browserViewModeProvider)) {
    BrowserViewMode.list => FileListView(parentPath: path, entries: listing.sortedEntries, padding: padding),
    BrowserViewMode.grid => FileGridView(parentPath: path, entries: listing.sortedEntries, padding: padding),
  };
}
