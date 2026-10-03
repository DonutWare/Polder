import "package:flutter/material.dart";

import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/byte_format.dart";
import "package:nomad/util/date_format_extension.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

class ConflictSideCard extends StatelessWidget {
  const ConflictSideCard({required this.title, required this.icon, this.size, this.modified, this.detail, super.key});

  final String title;
  final IconData icon;
  final int? size;
  final DateTime? modified;
  final String? detail;

  bool get _deleted => size == null && modified == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.inset,
        shape: squircle(AppRadius.inset, side: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              children: [
                IconBadge(icon: icon, size: 28, color: _deleted ? theme.colorScheme.error : null),
                Flexible(
                  child: Text(title, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_deleted) Text(context.localized.deleted, style: TextStyle(color: theme.colorScheme.error)),
            if (size != null) Text(ByteFormat.format(size!, locale: context.localeName)),
            if (modified != null) Text(modified!.formatted(context)),
            if (detail != null)
              Text(detail!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
