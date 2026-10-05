import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/screens/sync/widgets/conflict_dialog.dart";
import "package:polder/screens/sync/widgets/conflict_kind_text.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/icon_badge.dart";

class ConflictTile extends ConsumerWidget {
  const ConflictTile({required this.conflict, super.key});

  final Conflict conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolving = ref.watch(conflictQueueProvider.select((queue) => queue.isResolving(conflict)));
    return ListTile(
      leading: IconBadge(icon: IconsaxPlusLinear.document_copy, color: AppColors.of(context).warning),
      title: Text(conflict.relativePath, overflow: TextOverflow.ellipsis),
      subtitle: ConflictKindText(kind: conflict.kind),
      trailing: resolving
          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(IconsaxPlusLinear.arrow_right_3, size: 18),
      onTap: resolving ? null : () => showConflictDialog(context, conflict),
    );
  }
}
