import "package:flutter/material.dart";

import "package:nomad/theme/app_theme.dart";

class Tag extends StatelessWidget {
  const Tag({required this.text, required this.color, this.icon, super.key});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: ShapeDecoration(
      color: color.withValues(alpha: 0.16),
      shape: squircle(AppRadius.tag, side: tintedSide(color)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (icon != null) Icon(icon, size: 13, color: color),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    ),
  );
}
