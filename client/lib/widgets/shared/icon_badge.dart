import "package:flutter/material.dart";

import "package:nomad/theme/app_theme.dart";

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, this.icon, this.child, this.color, this.size = 36, this.shape})
    : assert(icon != null || child != null);

  final IconData? icon;
  final Widget? child;
  final Color? color;
  final double size;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    final dark = theme.brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: c.withValues(alpha: dark ? 0.22 : 0.15),
        shape: shape ?? squircle(size * 0.34, side: tintedSide(c)),
      ),
      alignment: Alignment.center,
      child: child ?? Icon(icon, size: size * 0.52, color: c),
    );
  }
}
