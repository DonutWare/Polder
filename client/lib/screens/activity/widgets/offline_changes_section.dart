import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/offline/offline_availability_provider.dart";
import "package:polder/providers/offline/offline_changes_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";

class OfflineChangesSection extends ConsumerWidget {
  const OfflineChangesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = [
      for (final change in ref.watch(offlineChangesProvider))
        if (!change.conflicted) change,
    ];
    if (changes.isEmpty) return const SizedBox.shrink();
    final localized = context.localized;
    final theme = Theme.of(context);
    final groups = {
      for (final group in OfflineChangeGroup.values)
        group: [
          for (final change in changes)
            if (change.group == group) change,
        ],
    }..removeWhere((_, members) => members.isEmpty);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(child: Text(localized.changesSavedOnDevice(changes.length), style: theme.textTheme.titleSmall)),
              TextButton.icon(
                icon: const Icon(IconsaxPlusLinear.refresh, size: 18),
                label: Text(localized.retryAll),
                onPressed: () => context.runWithFeedback(retryOfflineChanges(ref)),
              ),
            ],
          ),
          for (final MapEntry(key: group, value: members) in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _groupLabel(context, group),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Column(
              children: [
                for (final (index, change) in members.indexed)
                  GroupedTile(
                    index: index,
                    count: members.length,
                    child: OfflineChangeTile(key: ValueKey(change.key), change: change),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _groupLabel(BuildContext context, OfflineChangeGroup group) => switch (group) {
    OfflineChangeGroup.notes => context.localized.offlineGroupNotes,
    OfflineChangeGroup.files => context.localized.offlineGroupFiles,
    OfflineChangeGroup.calendar => context.localized.offlineGroupCalendar,
  };
}

class OfflineChangeTile extends ConsumerWidget {
  const OfflineChangeTile({required this.change, super.key});

  final OfflineChange change;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final cs = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final failing = change.failing;
    return ListTile(
      leading: Icon(switch (change.group) {
        OfflineChangeGroup.notes => IconsaxPlusLinear.note_2,
        OfflineChangeGroup.files => IconsaxPlusLinear.document_upload,
        OfflineChangeGroup.calendar => IconsaxPlusLinear.calendar_1,
      }, color: failing ? colors.warning : cs.onSurfaceVariant),
      title: Text(change.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        failing
            ? "${localized.syncFailedItem}: ${context.syncExplanation(change.error)}"
            : localized.syncWaitingForServer,
        maxLines: failing ? 4 : 1,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: failing,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (failing)
            IconButton(
              tooltip: localized.retrySync,
              icon: const Icon(IconsaxPlusLinear.refresh),
              onPressed: () => context.runWithFeedback(retryOfflineChanges(ref)),
            ),
          IconButton(
            tooltip: localized.discardChange,
            icon: const Icon(IconsaxPlusLinear.trash),
            onPressed: () => _discard(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.discardChangeTitle,
      message: localized.discardChangeMessage,
      confirmLabel: localized.discardChange,
      destructive: true,
    );
    if (confirmed && context.mounted) await context.runWithFeedback(discardOfflineChange(ref, change));
  }
}

class OfflineDownloadFailures extends ConsumerWidget {
  const OfflineDownloadFailures({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(offlineDownloadsProvider.select((downloads) => downloads.value?.failed ?? const {}));
    if (failed.isEmpty) return const SizedBox.shrink();
    final localized = context.localized;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GroupedTile(
        index: 0,
        count: 1,
        child: ListTile(
          leading: Icon(IconsaxPlusLinear.document_download, color: AppColors.of(context).warning),
          title: Text(localized.offlineDownloadsFailedSummary(failed.length)),
          subtitle: Text(context.syncHint(failed.values.first.error), maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: localized.retrySync,
            icon: const Icon(IconsaxPlusLinear.refresh),
            onPressed: () => context.runWithFeedback(retryOfflineChanges(ref)),
          ),
        ),
      ),
    );
  }
}
