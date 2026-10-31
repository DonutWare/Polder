import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/screens/browser/widgets/file_actions_row.dart";
import "package:polder/screens/browser/widgets/file_details_sheet.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/date_format_extension.dart";

class MediaInfoPanel extends StatelessWidget {
  const MediaInfoPanel({
    required this.entry,
    required this.asSheet,
    required this.onClose,
    required this.onRenamed,
    required this.onRemoved,
    super.key,
  });

  static const _sheetRadius = AppRadius.panel + 4;
  static const _thumbnailSize = 48.0;

  final FileEntry entry;
  final bool asSheet;
  final VoidCallback onClose;
  final ValueChanged<String> onRenamed;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final shape = asSheet
        ? RoundedSuperellipseBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
            side: BorderSide(color: colors.border),
          )
        : squircle(AppRadius.panel, side: BorderSide(color: colors.border));
    return Material(
      color: colors.panel,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: asSheet,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (asSheet) const _DragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                spacing: 12,
                children: [
                  FileThumbnail(entry: entry, dimension: _thumbnailSize, fill: true),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                        Text(
                          (entry.takenAt ?? entry.mtime).formatted(context),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (!asSheet)
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      icon: const Icon(IconsaxPlusLinear.close_circle),
                      onPressed: onClose,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FileActionsRow(
                      entry: entry,
                      onRenamed: onRenamed,
                      onRemoved: onRemoved,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(color: colors.inset, shape: squircle(AppRadius.inset + 4)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: FileDetailsList(entry: entry, closesRoute: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12),
      width: 32,
      height: 4,
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
