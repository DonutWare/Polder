import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/trash/trash_provider.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/trash/widgets/restore_conflict_dialog.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";

enum _TrashAction { restore, download, deletePermanently }

class TrashItemTile extends ConsumerWidget {
  const TrashItemTile({required this.item, super.key});

  final TrashItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final expiresAt = item.expiresAt;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      isThreeLine: true,
      leading: FileThumbnail.trashed(item: item, dimension: 40),
      title: Text(item.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          [
            localized.trashItemDeleted(item.deletedAt.formatted(context)),
            ByteFormat.format(item.size, locale: context.localeName),
          ].join(" · "),
          [
            localized.trashItemFrom(RemotePath.parent(item.originalPath)),
            if (expiresAt != null) localized.trashItemExpires(expiresAt.formatted(context)),
          ].join(" · "),
        ].join("\n"),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _TrashActionsMenu(item: item),
    );
  }
}

class _TrashActionsMenu extends ConsumerWidget {
  const _TrashActionsMenu({required this.item});

  final TrashItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    final localized = context.localized;
    return PopupMenuButton<_TrashAction>(
      icon: const Icon(IconsaxPlusLinear.more),
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) => [
        _item(_TrashAction.restore, IconsaxPlusLinear.rotate_left, localized.restore),
        _item(_TrashAction.download, IconsaxPlusLinear.document_download, localized.download),
        _item(_TrashAction.deletePermanently, IconsaxPlusLinear.trash, localized.deletePermanently, color: error),
      ],
    );
  }

  PopupMenuItem<_TrashAction> _item(_TrashAction action, IconData icon, String label, {Color? color}) => PopupMenuItem(
    value: action,
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: color == null ? null : TextStyle(color: color)),
    ),
  );

  Future<void> _handle(BuildContext context, WidgetRef ref, _TrashAction action) async {
    switch (action) {
      case _TrashAction.restore:
        await context.runWithFeedback(_restore(context, ref, item));
      case _TrashAction.download:
        await ref.read(transfersProvider.notifier).downloadFromTrash(item);
      case _TrashAction.deletePermanently:
        final confirmed = await showConfirmDialog(
          context,
          title: context.localized.deletePermanentlyTitle(item.name),
          message: context.localized.deletePermanentlyMessage,
          confirmLabel: context.localized.deletePermanently,
          destructive: true,
        );
        if (confirmed && context.mounted) {
          await context.runWithFeedback(ref.read(trashProvider.notifier).delete(item));
        }
    }
  }
}

Future<void> _restore(BuildContext context, WidgetRef ref, TrashItem item) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final localized = context.localized;
  final restored = await _restoreResolvingConflict(context, ref.read(trashProvider.notifier), item);
  if (restored != null) messenger?.showSnackBar(SnackBar(content: Text(localized.restoredTo(restored.path))));
}

Future<FileEntry?> _restoreResolvingConflict(BuildContext context, TrashNotifier trash, TrashItem item) async {
  try {
    return await trash.restore(item);
  } on AlreadyExistsException {
    if (!context.mounted) return null;
    final mode = await showRestoreConflictDialog(context, item);
    return mode == null ? null : trash.restore(item, onConflict: mode);
  }
}
