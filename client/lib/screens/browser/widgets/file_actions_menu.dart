import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/screens/browser/widgets/file_history_sheet.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";
import "package:polder/widgets/shared/icon_menu_item.dart";

enum _FileAction { edit, download, history, rename, move, delete }

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
        if (editable) iconMenuItem(_FileAction.edit, IconsaxPlusLinear.edit, context.localized.editorOpen),
        if (!entry.isDir)
          iconMenuItem(_FileAction.download, IconsaxPlusLinear.document_download, context.localized.download),
        if (!entry.isDir) iconMenuItem(_FileAction.history, IconsaxPlusLinear.clock, context.localized.versionHistory),
        iconMenuItem(_FileAction.rename, IconsaxPlusLinear.edit_2, context.localized.rename),
        iconMenuItem(_FileAction.move, IconsaxPlusLinear.folder_open, context.localized.move),
        iconMenuItem(_FileAction.delete, IconsaxPlusLinear.trash, context.localized.delete, color: error),
      ],
    );
  }

  Future<void> _handle(BuildContext context, WidgetRef ref, _FileAction action) async {
    final directory = ref.read(directoryProvider(parentPath).notifier);
    switch (action) {
      case _FileAction.edit:
        await context.push(AppRoutes.editor, extra: entry);
      case _FileAction.download:
        await ref.read(transfersProvider.notifier).download(entry);
      case _FileAction.history:
        await showFileHistory(context, entry);
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
        final keepsTrash = await ref
            .read(trashRetentionProvider.future)
            .then((retention) => retention.enabled, onError: (Object _) => true);
        if (!context.mounted) return;
        final confirmed = await showConfirmDialog(
          context,
          title: keepsTrash
              ? context.localized.deleteTitle(entry.name)
              : context.localized.deletePermanentlyTitle(entry.name),
          message: keepsTrash ? context.localized.deleteMessage : context.localized.deletePermanentlyMessage,
          confirmLabel: context.localized.delete,
          destructive: true,
        );
        if (confirmed && context.mounted) await context.runWithFeedback(directory.delete(entry));
    }
  }
}
