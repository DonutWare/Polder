import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:polder/models/activity.dart";
import "package:polder/screens/activity/widgets/activity_presentation.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/tag.dart";

class ActivityTile extends StatelessWidget {
  const ActivityTile({required this.entry, this.showUser = false, super.key});

  final ActivityEntry entry;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = entry.kind.style(context);
    final kindLabel = switch ((entry.kind, entry.detail)) {
      (ActivityKind.rescan, "added") => localized.activityRescanAdded,
      (ActivityKind.rescan, "removed") => localized.activityRescanRemoved,
      _ => entry.kind.label(context),
    };
    final title = switch (entry) {
      ActivityEntry(isSession: true) ||
      ActivityEntry(kind: ActivityKind.trashEmpty || ActivityKind.trashExpire) => kindLabel,
      ActivityEntry(kind: ActivityKind.rescan, detail: "summary") => localized.activityRescanSummary(entry.count ?? 0),
      ActivityEntry(name: "") => localized.activityAllFiles,
      _ => entry.name,
    };
    final failed = entry.status != ActivityStatus.ok;
    final details = [
      if (title != kindLabel && entry.detail != "summary") kindLabel,
      if (entry.fromPath case final from?) localized.activityMovedFrom(from),
      if (entry.count case final count? when entry.kind != ActivityKind.rescan) localized.activityItemCount(count),
      ?_transferred(context),
      entry.device,
      if (failed && entry.detail.isNotEmpty) entry.detail,
    ];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: IconBadge(icon: icon, color: failed ? cs.error : color),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(details.join(" · "), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (showUser || failed)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (showUser) Tag(text: entry.username, color: AppColors.of(context).sky),
                if (entry.status == ActivityStatus.failed) Tag(text: localized.activityFailed, color: cs.error),
                if (entry.status == ActivityStatus.cancelled) Tag(text: localized.activityCancelled, color: cs.outline),
              ],
            ),
        ],
      ),
      trailing: Text(
        DateFormat.Hm(context.localeName).format(entry.createdAt.toLocal()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String? _transferred(BuildContext context) {
    final amount = entry.bytes ?? entry.size;
    if (amount == null || entry.isDir && entry.count == null) return null;
    final bytes = ByteFormat.format(amount, locale: context.localeName);
    final duration = entry.durationMs;
    return duration == null || entry.bytes == null ? bytes : "$bytes · ${formatDuration(context, duration)}";
  }
}
