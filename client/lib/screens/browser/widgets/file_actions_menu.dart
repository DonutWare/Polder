import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_mount.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/device/wallpaper.dart";
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
import "package:polder/widgets/tags/tag_picker.dart";

enum FileAction { open, edit, download, share, shareDetails, history, wallpaper, rename, tags, copy, move, delete }

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

  static List<FileAction> available(WidgetRef ref, List<FileEntry> entries) {
    if (entries.isEmpty) return const [];
    final single = entries.length == 1 ? entries.single : null;
    final inShare = entries.any((entry) => entry.mount != null);
    bool allowed(bool Function(SharePermissions permissions) test) => _allowed(entries, test);
    return [
      if (single != null) FileAction.open,
      if (single != null && (ref.read(editorCapabilitiesProvider).value?.canOpen(single) ?? false)) FileAction.edit,
      if (entries.any((entry) => !entry.isDir)) FileAction.download,
      if (single != null && !inShare) FileAction.share,
      if (single?.mount != null) FileAction.shareDetails,
      if (single != null && !single.isDir && !inShare) FileAction.history,
      if (single != null && Wallpaper.canUse(single)) FileAction.wallpaper,
      if (single != null && allowed((permissions) => permissions.edit)) FileAction.rename,
      if (canTag(entries)) FileAction.tags,
      if (allowed((permissions) => permissions.create)) FileAction.copy,
      if (canMove(entries)) FileAction.move,
      if (allowed((permissions) => permissions.delete)) FileAction.delete,
    ];
  }

  static IconData iconOf(FileAction action) => switch (action) {
    FileAction.open => IconsaxPlusLinear.export_3,
    FileAction.edit => IconsaxPlusLinear.edit,
    FileAction.download => IconsaxPlusLinear.document_download,
    FileAction.share => IconsaxPlusLinear.share,
    FileAction.shareDetails => IconsaxPlusLinear.people,
    FileAction.history => IconsaxPlusLinear.clock,
    FileAction.wallpaper => IconsaxPlusLinear.gallery_tick,
    FileAction.rename => IconsaxPlusLinear.edit_2,
    FileAction.tags => IconsaxPlusLinear.tag,
    FileAction.copy => IconsaxPlusLinear.copy,
    FileAction.move => IconsaxPlusLinear.folder_open,
    FileAction.delete => IconsaxPlusLinear.trash,
  };

  static String labelOf(BuildContext context, FileAction action) => switch (action) {
    FileAction.open => context.localized.open,
    FileAction.edit => context.localized.editorOpen,
    FileAction.download => context.localized.download,
    FileAction.share => context.localized.share,
    FileAction.shareDetails => context.localized.shareDetailsTitle,
    FileAction.history => context.localized.versionHistory,
    FileAction.wallpaper => Wallpaper.opensChooser ? context.localized.setAs : context.localized.setAsWallpaper,
    FileAction.rename => context.localized.rename,
    FileAction.tags => context.localized.tagsAction,
    FileAction.copy => context.localized.copy,
    FileAction.move => context.localized.move,
    FileAction.delete => context.localized.delete,
  };

  static Future<void> showMenuFor(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
    required RelativeRect position,
  }) async {
    final error = Theme.of(context).colorScheme.error;
    final action = await showMenu<FileAction>(
      context: context,
      position: position,
      items: [
        for (final action in available(ref, entries))
          iconMenuItem(
            action,
            iconOf(action),
            labelOf(context, action),
            color: action == FileAction.delete ? error : null,
          ),
      ],
    );
    if (action == null || !context.mounted) return;
    await perform(context, ref, action, parentPath: parentPath, entries: entries);
  }

  static Future<void> perform(
    BuildContext context,
    WidgetRef ref,
    FileAction action, {
    required String parentPath,
    required List<FileEntry> entries,
    ValueChanged<String>? onRenamed,
    VoidCallback? onRemoved,
  }) async {
    final single = entries.length == 1 ? entries.single : null;
    switch (action) {
      case FileAction.open:
        await openEntry(context, single!);
      case FileAction.edit:
        await context.push(AppRoutes.editor, extra: single);
      case FileAction.download:
        final transfers = ref.read(transfersProvider.notifier);
        for (final entry in entries.where((entry) => !entry.isDir)) {
          await transfers.download(entry);
        }
      case FileAction.share:
        await showSharePanel(context, SharedFile.of(single!));
      case FileAction.shareDetails:
        await showMountDetails(context, single!);
      case FileAction.history:
        await showFileHistory(context, single!);
      case FileAction.wallpaper:
        await setWallpaper(context, ref, single!);
      case FileAction.rename:
        final renamed = await rename(context, ref, parentPath: parentPath, entry: single!);
        if (renamed != null) onRenamed?.call(renamed);
      case FileAction.tags:
        await showTagPicker(context, entries);
      case FileAction.copy:
        await copy(context, ref, parentPath: parentPath, entries: entries);
      case FileAction.move:
        if (await move(context, ref, parentPath: parentPath, entries: entries)) onRemoved?.call();
      case FileAction.delete:
        if (await delete(context, ref, parentPath: parentPath, entries: entries)) onRemoved?.call();
    }
  }

  static Future<void> setWallpaper(BuildContext context, WidgetRef ref, FileEntry entry) async {
    final api = ref.read(polderApiProvider);
    final title = context.localized.setAs;
    final done = await context.runWithFeedback(
      api.downloadBytes(entry.path).then((bytes) => Wallpaper.set(bytes, name: entry.name, chooserTitle: title)),
    );
    if (done && !Wallpaper.opensChooser && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(context.localized.wallpaperSet)));
    }
  }

  static bool canTag(List<FileEntry> entries) =>
      entries.every((entry) => entry.id != 0 && entry.mount?.kind != FileMountKind.federated);

  static Future<String?> rename(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required FileEntry entry,
  }) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    final name = await promptRename(context, entry);
    if (name == null || !context.mounted) return null;
    final renamed = await context.runWithFeedback(directory.rename(entry, name));
    return renamed ? RemotePath.join(parentPath, name) : null;
  }

  static Future<bool> move(
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
    if (destination == null || !context.mounted) return false;
    return context.runWithFeedback(directory.moveAllTo(entries, destination));
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

  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref, {
    required String parentPath,
    required List<FileEntry> entries,
  }) async {
    if (entries.isEmpty) return false;
    final directory = ref.read(directoryProvider(parentPath).notifier);
    final keepsTrash = await ref
        .read(trashRetentionProvider.future)
        .then((retention) => retention.enabled, onError: (Object _) => true);
    if (!context.mounted) return false;
    final confirmed = await confirmDelete(context, entries, keepsTrash: keepsTrash);
    if (!confirmed || !context.mounted) return false;
    return context.runWithFeedback(directory.deleteAll(entries));
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
