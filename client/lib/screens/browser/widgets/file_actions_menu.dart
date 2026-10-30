import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_history_sheet.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/screens/browser/widgets/mount_details_sheet.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/file_dialogs.dart";
import "package:polder/widgets/shared/icon_menu_item.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";
import "package:polder/widgets/sharing/share_panel.dart";

enum _FileAction { open, edit, download, share, shareDetails, history, rename, copy, move, delete }

abstract final class FileActions {
  static RelativeRect menuPositionAt(BuildContext context, Offset globalPosition) {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    return RelativeRect.fromRect(overlay.globalToLocal(globalPosition) & Size.zero, Offset.zero & overlay.size);
  }

  static RelativeRect menuPositionBelow(BuildContext context) {
    final button = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    return RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
  }

  static Future<void> showMenuFor(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
    required RelativeRect position,
  }) async {
    if (entries.isEmpty) return;
    final single = entries.length == 1 ? entries.single : null;
    final inShare = entries.any((entry) => entry.mount != null);
    bool allowed(bool Function(SharePermissions permissions) test) => _allowed(entries, test);
    final editable = single != null && (ref.read(editorCapabilitiesProvider).value?.canOpen(single) ?? false);
    final hasFiles = entries.any((entry) => !entry.isDir);
    final error = Theme.of(context).colorScheme.error;
    final action = await showMenu<_FileAction>(
      context: context,
      position: position,
      items: [
        if (single != null) iconMenuItem(_FileAction.open, IconsaxPlusLinear.export_3, context.localized.open),
        if (editable) iconMenuItem(_FileAction.edit, IconsaxPlusLinear.edit, context.localized.editorOpen),
        if (hasFiles)
          iconMenuItem(_FileAction.download, IconsaxPlusLinear.document_download, context.localized.download),
        if (single != null && !inShare)
          iconMenuItem(_FileAction.share, IconsaxPlusLinear.share, context.localized.share),
        if (single?.mount != null)
          iconMenuItem(_FileAction.shareDetails, IconsaxPlusLinear.people, context.localized.shareDetailsTitle),
        if (single != null && !single.isDir && !inShare)
          iconMenuItem(_FileAction.history, IconsaxPlusLinear.clock, context.localized.versionHistory),
        if (single != null && allowed((permissions) => permissions.edit))
          iconMenuItem(_FileAction.rename, IconsaxPlusLinear.edit_2, context.localized.rename),
        if (allowed((permissions) => permissions.create))
          iconMenuItem(_FileAction.copy, IconsaxPlusLinear.copy, context.localized.copy),
        if (canMove(entries)) iconMenuItem(_FileAction.move, IconsaxPlusLinear.folder_open, context.localized.move),
        if (allowed((permissions) => permissions.delete))
          iconMenuItem(_FileAction.delete, IconsaxPlusLinear.trash, context.localized.delete, color: error),
      ],
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _FileAction.open:
        await openEntry(context, single!);
      case _FileAction.edit:
        await context.push(AppRoutes.editor, extra: single);
      case _FileAction.download:
        final transfers = ref.read(transfersProvider.notifier);
        for (final entry in entries.where((entry) => !entry.isDir)) {
          await transfers.download(entry);
        }
      case _FileAction.share:
        await showSharePanel(context, SharedFile.of(single!));
      case _FileAction.shareDetails:
        await showMountDetails(context, single!);
      case _FileAction.history:
        await showFileHistory(context, single!);
      case _FileAction.rename:
        await rename(context, ref, parentPath: parentPath, entry: single!);
      case _FileAction.copy:
        await copy(context, ref, parentPath: parentPath, entries: entries);
      case _FileAction.move:
        await move(context, ref, parentPath: parentPath, entries: entries);
      case _FileAction.delete:
        await delete(context, ref, parentPath: parentPath, entries: entries);
    }
  }

  static Future<void> rename(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required FileEntry entry,
  }) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    final name = await promptRename(context, entry);
    if (name != null && context.mounted) await context.runWithFeedback(directory.rename(entry, name));
  }

  static Future<void> move(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
  }) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    final destination = await showRemoteFolderPicker(
      context,
      initialPath: parentPath,
      title: entries.length == 1
          ? context.localized.moveEntryTitle(entries.single.name)
          : context.localized.moveItemsTitle(entries.length),
      confirmLabel: context.localized.moveHere,
      excluded: _folders(entries),
      canChoose: (path) => path != parentPath && _withinSameShare(ref, entries, path),
    );
    if (destination == null || !context.mounted) return;
    await context.runWithFeedback(directory.moveAllTo(entries, destination));
  }

  static Future<void> copy(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
  }) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    // Picking the folder the entries are in duplicates them there.
    final destination = await showRemoteFolderPicker(
      context,
      initialPath: parentPath,
      title: entries.length == 1
          ? context.localized.copyEntryTitle(entries.single.name)
          : context.localized.copyItemsTitle(entries.length),
      confirmLabel: context.localized.copyHere,
      excluded: _folders(entries),
      canChoose: (path) => _withinSameShare(ref, entries, path),
    );
    if (destination == null || !context.mounted) return;
    await context.runWithFeedback(directory.copyAllTo(entries, destination, copySuffix: context.localized.copySuffix));
  }

  static bool _allowed(List<FileEntry> entries, bool Function(SharePermissions permissions) test) =>
      !entries.any((entry) => entry.isMountRoot) &&
      entries.every((entry) => entry.mount == null || test(entry.mount!.permissions));

  static bool canMove(List<FileEntry> entries) =>
      _allowed(entries, (permissions) => permissions.create && permissions.delete);

  static bool canMoveInto(
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
    required String destination,
  }) =>
      destination != parentPath &&
      !entries.any((entry) => entry.path == destination || RemotePath.isWithin(destination, entry.path)) &&
      _withinSameShare(ref, entries, destination);

  static bool _withinSameShare(WidgetRef ref, List<FileEntry> entries, String destination) {
    if (entries.first.mount case final mount?) return mount.contains(destination);
    final mounts = ref.read(directoryProvider(RemotePath.root)).value?.entries.where((entry) => entry.isMountRoot);
    return !(mounts ?? const <FileEntry>[]).any((entry) => entry.mount!.contains(destination));
  }

  // Folders can't go into themselves, so the picker greys them out.
  static Set<String> _folders(List<FileEntry> entries) => {
    for (final entry in entries)
      if (entry.isDir) entry.path,
  };

  static Future<void> delete(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
  }) async {
    if (entries.isEmpty) return;
    final directory = ref.read(directoryProvider(parentPath).notifier);
    final keepsTrash = await ref
        .read(trashRetentionProvider.future)
        .then((retention) => retention.enabled, onError: (Object _) => true);
    if (!context.mounted) return;
    final confirmed = await confirmDelete(context, entries, keepsTrash: keepsTrash);
    if (confirmed && context.mounted) await context.runWithFeedback(directory.deleteAll(entries));
  }
}

/// The "more" button on a tile for pointer devices; touch opens the same menu with a long press.
class FileActionsButton extends StatelessWidget {
  const FileActionsButton({required this.onPressed, super.key});

  final void Function(RelativeRect position) onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.localized.moreOptions,
    icon: const Icon(IconsaxPlusLinear.more),
    onPressed: () => onPressed(FileActions.menuPositionBelow(context)),
  );
}
