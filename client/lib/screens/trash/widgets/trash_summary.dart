import "package:flutter/material.dart";

import "package:polder/models/trash.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/retention_picker_dialog.dart";

String retentionHint(BuildContext context, TrashRetention retention) => retention.keepsForever
    ? context.localized.trashRetentionForeverHint
    : context.localized.trashRetentionHint(context.retentionDuration(retention.days));

class TrashSummary extends StatelessWidget {
  const TrashSummary({required this.listing, super.key});

  final TrashListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = ByteFormat.format(listing.totalBytes, locale: context.localeName);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(context.localized.trashSummary(listing.items.length, size), style: theme.textTheme.titleSmall),
          Text(
            retentionHint(context, listing.retention),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
