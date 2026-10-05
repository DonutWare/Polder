import "package:flutter/material.dart";

import "package:polder/theme/app_theme.dart";

class NoticeTile extends StatelessWidget {
  const NoticeTile({required this.icon, required this.text, required this.color, this.action, super.key});

  final IconData icon;
  final String text;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.13),
        shape: squircle(AppRadius.inset, side: tintedSide(color)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, size: 20, color: color),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
          ),
          ?action,
        ],
      ),
    );
  }
}
