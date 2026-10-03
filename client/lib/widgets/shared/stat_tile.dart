import "package:flutter/material.dart";

import "package:nomad/theme/app_theme.dart";
import "package:nomad/widgets/shared/icon_badge.dart";
import "package:nomad/widgets/shared/level_bar.dart";

class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.caption,
    this.fraction,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final String? caption;

  final double? fraction;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final level = fraction == null ? null : AppColors.of(context).forLevel(context, fraction);
    final accent = color ?? level ?? cs.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconBadge(icon: icon, color: accent, size: 34, shape: AppShapes.cookie),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: value),
                    if (unit != null)
                      TextSpan(
                        text: " $unit",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 10),
            if (fraction != null) LevelBar(fraction: fraction, color: level) else const SizedBox(height: 8),
            const SizedBox(height: 8),
            Text(
              caption ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
