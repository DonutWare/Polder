import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/screens/browser/widgets/file_metadata_text.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/file_dialogs.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/refreshable_empty_view.dart";

enum _EntryAction { download, rename, delete }

class SpaceDirectoryView extends ConsumerWidget {
  const SpaceDirectoryView({required this.location, required this.onOpenFolder, super.key});

  final SpaceLocation location;
  final ValueChanged<String> onOpenFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(spaceDirectoryProvider(location).notifier);
    return AsyncValueView<DirectoryListing>(
      value: ref.watch(spaceDirectoryProvider(location)),
      onRetry: notifier.refresh,
      data: (listing) {
        final entries = listing.sortedEntries;
        return ReadableWidth(
          maxWidth: 1200,
          builder: (context, inset) => RefreshIndicator(
            edgeOffset: inset.top,
            onRefresh: notifier.refresh,
            child: entries.isEmpty
                ? RefreshableEmptyView(
                    child: MessageView(icon: IconsaxPlusLinear.folder_open, message: context.localized.emptyFolder),
                  )
                : ListView.builder(
                    padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: entries.length,
                    itemBuilder: (context, index) =>
                        _SpaceEntryTile(location: location, entry: entries[index], onOpenFolder: onOpenFolder),
                  ),
          ),
        );
      },
    );
  }
}

class _SpaceEntryTile extends ConsumerWidget {
  const _SpaceEntryTile({required this.location, required this.entry, required this.onOpenFolder});

  final SpaceLocation location;
  final FileEntry entry;
  final ValueChanged<String> onOpenFolder;

  FileSpace get space => location.space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final capabilities = ref.watch(spaceCapabilitiesProvider(space));
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      leading: FileThumbnail.inSpace(space: space, entry: entry, dimension: 40),
      title: Text(entry.name, overflow: TextOverflow.ellipsis),
      subtitle: FileMetadataText(entry: entry),
      onTap: () => entry.isDir ? onOpenFolder(entry.path) : showSpaceFileSheet(context, space, entry),
      trailing: PopupMenuButton<_EntryAction>(
        icon: const Icon(IconsaxPlusLinear.more),
        onSelected: (action) => switch (action) {
          _EntryAction.download => ref.read(transfersProvider.notifier).downloadFromSpace(space, entry),
          _EntryAction.rename => _rename(context, ref),
          _EntryAction.delete => _delete(context, ref),
        },
        itemBuilder: (context) => [
          if (capabilities.canDownload)
            PopupMenuItem(
              value: _EntryAction.download,
              child: ListTile(
                leading: const Icon(IconsaxPlusLinear.document_download),
                title: Text(localized.download),
              ),
            ),
          if (capabilities.canEdit)
            PopupMenuItem(
              value: _EntryAction.rename,
              child: ListTile(leading: const Icon(IconsaxPlusLinear.edit_2), title: Text(localized.rename)),
            ),
          if (capabilities.canDelete)
            PopupMenuItem(
              value: _EntryAction.delete,
              child: ListTile(
                leading: Icon(IconsaxPlusLinear.trash, color: colors.error),
                title: Text(localized.delete, style: TextStyle(color: colors.error)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await promptRename(context, entry);
    if (name == null || !context.mounted) return;
    await context.runWithFeedback(ref.read(spaceDirectoryProvider(location).notifier).rename(entry, name));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDelete(context, [entry]);
    if (confirmed && context.mounted) {
      await context.runWithFeedback(ref.read(spaceDirectoryProvider(location).notifier).delete(entry));
    }
  }
}

Future<void> showSpaceFileSheet(BuildContext context, FileSpace space, FileEntry entry) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => SpaceFileSheet(space: space, entry: entry),
);

class SpaceFileSheet extends ConsumerWidget {
  const SpaceFileSheet({required this.space, required this.entry, super.key});

  final FileSpace space;
  final FileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          FileThumbnail.inSpace(space: space, entry: entry, dimension: 220, fill: true),
          Text(entry.name, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          FileMetadataText(entry: entry),
          if (ref.watch(spaceCapabilitiesProvider(space)).canDownload)
            FilledButton.icon(
              icon: const Icon(IconsaxPlusLinear.document_download),
              label: Text(context.localized.download),
              onPressed: () {
                Navigator.pop(context);
                ref.read(transfersProvider.notifier).downloadFromSpace(space, entry);
              },
            ),
        ],
      ),
    ),
  );
}
