import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/theme/app_theme.dart";

/// The app's mark: an accent gradient on a cookie shape.
class AppMark extends StatelessWidget {
  const AppMark({this.icon = IconsaxPlusBold.cloud, this.size = 36, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: AppShapes.cookie,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
      ),
      child: Icon(icon, size: size * 0.53, color: cs.onPrimary),
    );
  }
}
