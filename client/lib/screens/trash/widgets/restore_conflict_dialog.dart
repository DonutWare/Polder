import "package:flutter/material.dart";

import "package:nomad/models/trash.dart";
import "package:nomad/util/localization_helper.dart";

Future<RestoreMode?> showRestoreConflictDialog(BuildContext context, TrashItem item) => showDialog<RestoreMode>(
  context: context,
  builder: (_) => RestoreConflictDialog(item: item),
);

class RestoreConflictDialog extends StatelessWidget {
  const RestoreConflictDialog({required this.item, super.key});

  static const overwriteKey = Key("restoreConflict.overwrite");
  static const keepBothKey = Key("restoreConflict.keepBoth");

  final TrashItem item;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.restoreConflictTitle(item.name), overflow: TextOverflow.ellipsis),
      content: SizedBox(width: 420, child: Text(localized.restoreConflictMessage(item.originalPath))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        OutlinedButton(
          key: overwriteKey,
          onPressed: () => Navigator.pop(context, RestoreMode.overwrite),
          child: Text(localized.overwrite),
        ),
        FilledButton(
          key: keepBothKey,
          onPressed: () => Navigator.pop(context, RestoreMode.keepBoth),
          child: Text(localized.keepBoth),
        ),
      ],
    );
  }
}
