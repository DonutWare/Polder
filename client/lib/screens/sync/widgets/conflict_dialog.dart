import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/conflict.dart";
import "package:nomad/providers/sync/conflict_queue_provider.dart";
import "package:nomad/screens/sync/widgets/apply_to_all_checkbox.dart";
import "package:nomad/screens/sync/widgets/conflict_details.dart";
import "package:nomad/screens/sync/widgets/conflict_kind_text.dart";
import "package:nomad/util/localization_helper.dart";

Future<void> showConflictDialog(BuildContext context, Conflict conflict) => showDialog<void>(
  context: context,
  builder: (_) => ConflictDialog(conflict: conflict),
);

class ConflictDialog extends ConsumerWidget {
  const ConflictDialog({required this.conflict, super.key});

  static const keepMineKey = Key("conflict.keepMine");
  static const keepServerKey = Key("conflict.keepServer");
  static const keepBothKey = Key("conflict.keepBoth");

  final Conflict conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    void choose(ConflictResolution resolution) {
      ref.read(conflictQueueProvider.notifier).choose(conflict, resolution);
      Navigator.pop(context);
    }

    return AlertDialog(
      title: Text(conflict.name, overflow: TextOverflow.ellipsis),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            ConflictKindText(kind: conflict.kind),
            ConflictDetails(conflict: conflict),
            const ApplyToAllCheckbox(),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: keepBothKey,
          onPressed: () => choose(ConflictResolution.keepBoth),
          child: Text(localized.keepBoth),
        ),
        OutlinedButton(
          key: keepServerKey,
          onPressed: () => choose(ConflictResolution.keepServer),
          child: Text(localized.keepServer),
        ),
        FilledButton(
          key: keepMineKey,
          onPressed: () => choose(ConflictResolution.keepMine),
          child: Text(localized.keepMine),
        ),
      ],
    );
  }
}
