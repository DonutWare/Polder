import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/versions/file_versions_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/icon_menu_item.dart";

typedef VersionViewer = void Function(FileVersion version);

typedef VersionRestorer = Future<void> Function(FileVersion version);

Future<void> showFileHistory(
  BuildContext context,
  FileEntry entry, {
  VersionViewer? onView,
  VersionRestorer? onRestore,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => FileHistorySheet(entry: entry, onView: onView, onRestore: onRestore),
);

enum _VersionAction { view, download, restore, delete }

class FileHistorySheet extends ConsumerWidget {
  const FileHistorySheet({required this.entry, this.onView, this.onRestore, super.key});

  final FileEntry entry;
  final VersionViewer? onView;
  final VersionRestorer? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(fileVersionsProvider(entry.path));
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(context.localized.versionHistory, style: Theme.of(context).textTheme.titleLarge),
            ),
            Flexible(
              child: AsyncValueView<VersionListing>(
                value: listing,
                onRetry: () => ref.invalidate(fileVersionsProvider(entry.path)),
                data: (listing) =>
                    _VersionList(entry: listing.current, listing: listing, onView: onView, onRestore: onRestore),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionList extends ConsumerWidget {
  const _VersionList({required this.entry, required this.listing, required this.onView, required this.onRestore});

  final FileEntry entry;
  final VersionListing listing;
  final VersionViewer? onView;
  final VersionRestorer? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final locale = context.localeName;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        ListTile(
          leading: FileThumbnail(entry: entry, dimension: 48),
          title: Text(localized.versionCurrent),
          subtitle: Text("${entry.mtime.formatted(context)} · ${ByteFormat.format(entry.size, locale: locale)}"),
        ),
        const Divider(),
        if (listing.versions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              listing.retention.enabled ? localized.versionHistoryEmpty : localized.versionHistoryOff,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        for (final version in listing.versions)
          ListTile(
            leading: FileThumbnail.version(entry: entry, version: version, dimension: 48),
            title: Text(version.modifiedAt.formatted(context)),
            subtitle: Text(ByteFormat.format(version.size, locale: locale)),
            trailing: _VersionMenu(entry: entry, version: version, onView: onView, onRestore: onRestore),
          ),
      ],
    );
  }
}

class _VersionMenu extends ConsumerWidget {
  const _VersionMenu({required this.entry, required this.version, required this.onView, required this.onRestore});

  final FileEntry entry;
  final FileVersion version;
  final VersionViewer? onView;
  final VersionRestorer? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final error = Theme.of(context).colorScheme.error;
    final viewable = ref.watch(editorCapabilitiesProvider).value?.canOpen(entry) ?? false;
    return PopupMenuButton<_VersionAction>(
      icon: const Icon(IconsaxPlusLinear.more),
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) => [
        if (viewable) iconMenuItem(_VersionAction.view, IconsaxPlusLinear.eye, localized.versionView),
        iconMenuItem(_VersionAction.download, IconsaxPlusLinear.document_download, localized.download),
        iconMenuItem(_VersionAction.restore, IconsaxPlusLinear.rotate_left, localized.versionRestore),
        iconMenuItem(_VersionAction.delete, IconsaxPlusLinear.trash, localized.delete, color: error),
      ],
    );
  }

  Future<void> _handle(BuildContext context, WidgetRef ref, _VersionAction action) async {
    final versions = ref.read(fileVersionsProvider(entry.path).notifier);
    final localized = context.localized;
    switch (action) {
      case _VersionAction.view:
        Navigator.pop(context);
        if (onView case final view?) {
          view(version);
        } else {
          await context.push(AppRoutes.editor, extra: EditorTarget(entry, version: version));
        }
      case _VersionAction.download:
        await ref.read(transfersProvider.notifier).downloadVersion(entry, version);
      case _VersionAction.restore:
        final confirmed = await showConfirmDialog(
          context,
          title: localized.versionRestoreTitle,
          message: localized.versionRestoreMessage,
          confirmLabel: localized.versionRestore,
        );
        if (!confirmed || !context.mounted) return;
        if (onRestore case final restore?) {
          Navigator.pop(context);
          await restore(version);
          return;
        }
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (await context.runWithFeedback(versions.restore(version))) {
          messenger?.showSnackBar(SnackBar(content: Text(localized.versionRestored)));
        }
      case _VersionAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: localized.versionDeleteTitle,
          message: localized.versionDeleteMessage,
          confirmLabel: localized.delete,
          destructive: true,
        );
        if (confirmed && context.mounted) await context.runWithFeedback(versions.delete(version));
    }
  }
}
