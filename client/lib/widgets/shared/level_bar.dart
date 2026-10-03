import "package:flutter/material.dart";

import "package:nomad/theme/app_theme.dart";

class LevelBar extends StatelessWidget {
  const LevelBar({required this.fraction, this.color, this.height = 8, super.key});

  final double? fraction;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.of(context).forLevel(context, fraction);
    return LinearProgressIndicator(
      value: fraction?.clamp(0.0, 1.0),
      color: c,
      backgroundColor: c.withValues(alpha: 0.2),
      minHeight: height,
      borderRadius: BorderRadius.circular(height),
    );
  }
}
