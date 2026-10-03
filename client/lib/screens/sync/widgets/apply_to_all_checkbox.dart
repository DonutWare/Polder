import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/providers/sync/conflict_queue_provider.dart";
import "package:nomad/util/localization_helper.dart";

class ApplyToAllCheckbox extends ConsumerWidget {
  const ApplyToAllCheckbox({super.key});

  static const checkboxKey = Key("conflict.applyToAll");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(conflictQueueProvider);
    if (queue.conflicts.length < 2) return const SizedBox.shrink();
    return CheckboxListTile(
      key: checkboxKey,
      value: queue.applyToAll,
      title: Text(context.localized.applyToAll(queue.conflicts.length)),
      onChanged: (value) => ref.read(conflictQueueProvider.notifier).setApplyToAll(value ?? false),
    );
  }
}
