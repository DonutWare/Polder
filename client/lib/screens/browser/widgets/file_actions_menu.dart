import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

enum _FileAction { edit, download, rename, move, delete }

class FileActionsMenu extends ConsumerWidget {
  const FileActionsMenu({required this.parentPath, required this.entry, super.key});

  final String parentPath;
  final FileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    final editable = ref.watch(editorCapabilitiesProvider).value?.canOpen(entry) ?? false;
    return PopupMenuButton<_FileAction>(
      icon: const Icon(IconsaxPlusLinear.more),
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) => [
        if (editable) _item(_FileAction.edit, IconsaxPlusLinear.edit, context.localized.editorOpen),
        if (!entry.isDir) _item(_FileAction.download, IconsaxPlusLinear.document_download, context.localized.download),
        _item(_FileAction.rename, IconsaxPlusLinear.edit_2, context.localized.rename),
        _item(_FileAction.move, IconsaxPlusLinear.folder_open, context.localized.move),
        _item(_FileAction.delete, IconsaxPlusLinear.trash, context.localized.delete, color: error),
      ],
    );
  }

  PopupMenuItem<_FileAction> _item(_FileAction action, IconData icon, String label, {Color? color}) => PopupMenuItem(
    value: action,
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: color == null ? null : TextStyle(color: color)),
    ),
  );

  Future<void> _handle(BuildContext context, WidgetRef ref, _FileAction action) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    switch (action) {
      case _FileAction.edit:
        await context.push(AppRoutes.editor, extra: entry);
      case _FileAction.download:
        await ref.read(transfersProvider.notifier).download(entry);
      case _FileAction.rename:
        final name = await showTextInputDialog(
          context,
          title: context.localized.rename,
          label: context.localized.name,
          confirmLabel: context.localized.rename,
          initialValue: entry.name,
          isValid: (value) => RemotePath.isValidName(value.trim()) && value.trim() != entry.name,
        );
        if (name != null && context.mounted) await context.runWithFeedback(directory.rename(entry, name));
      case _FileAction.move:
        final destination = await showRemoteFolderPicker(context, initialPath: parentPath);
        if (destination != null && destination != parentPath && context.mounted) {
          await context.runWithFeedback(directory.moveTo(entry, destination));
        }
      case _FileAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: context.localized.deleteTitle(entry.name),
          message: context.localized.deleteMessage,
          confirmLabel: context.localized.delete,
          destructive: true,
        );
        if (confirmed && context.mounted) await context.runWithFeedback(directory.delete(entry));
    }
  }
}
