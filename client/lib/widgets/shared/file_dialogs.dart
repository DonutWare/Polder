import "package:flutter/material.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

Future<String?> promptFolderName(BuildContext context) => showTextInputDialog(
  context,
  title: context.localized.newFolder,
  label: context.localized.name,
  confirmLabel: context.localized.create,
  isValid: (value) => RemotePath.isValidName(value.trim()),
);

Future<String?> promptRename(BuildContext context, FileEntry entry) => showTextInputDialog(
  context,
  title: context.localized.rename,
  label: context.localized.name,
  confirmLabel: context.localized.rename,
  initialValue: entry.name,
  isValid: (value) => RemotePath.isValidName(value.trim()) && value.trim() != entry.name,
);

Future<bool> confirmDelete(BuildContext context, List<FileEntry> entries, {bool keepsTrash = true}) {
  final localized = context.localized;
  final single = entries.length == 1 ? entries.single : null;
  return showConfirmDialog(
    context,
    title: switch ((keepsTrash, single)) {
      (true, final FileEntry entry) => localized.deleteTitle(entry.name),
      (false, final FileEntry entry) => localized.deletePermanentlyTitle(entry.name),
      (true, null) => localized.deleteItemsTitle(entries.length),
      (false, null) => localized.deletePermanentlyItemsTitle(entries.length),
    },
    message: keepsTrash ? localized.deleteMessage : localized.deletePermanentlyMessage,
    confirmLabel: localized.delete,
    destructive: true,
  );
}
