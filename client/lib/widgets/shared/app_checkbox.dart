import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/theme/app_theme.dart";

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      checked: value,
      child: IconButton(
        onPressed: onChanged == null ? null : () => onChanged!(!value),
        icon: AnimatedSwitcher(
          duration: AppMotion.effectsDuration,
          switchInCurve: AppMotion.effects,
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: value
              ? Icon(IconsaxPlusBold.tick_square, key: const ValueKey(true), color: cs.primary)
              : Icon(IconsaxPlusLinear.stop, key: const ValueKey(false), color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
