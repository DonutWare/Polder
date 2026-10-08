import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/app_checkbox.dart";

class ApplyToAllCheckbox extends ConsumerWidget {
  const ApplyToAllCheckbox({super.key});

  static const checkboxKey = Key("conflict.applyToAll");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(conflictQueueProvider);
    if (queue.conflicts.length < 2) return const SizedBox.shrink();
    final notifier = ref.read(conflictQueueProvider.notifier);
    return ListTile(
      key: checkboxKey,
      title: Text(context.localized.applyToAll(queue.conflicts.length)),
      trailing: AppCheckbox(value: queue.applyToAll, onChanged: notifier.setApplyToAll),
      onTap: () => notifier.setApplyToAll(!queue.applyToAll),
    );
  }
}
