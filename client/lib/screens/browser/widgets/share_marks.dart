import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/util/localization_helper.dart";

class SharedByYouMark extends StatelessWidget {
  const SharedByYouMark({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.localized.sharedByYou,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(IconsaxPlusLinear.share, size: 18, color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class SharedWithYouBadge extends StatelessWidget {
  const SharedWithYouBadge({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: context.localized.sharedWithYou,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.surface, width: 1.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.18),
          child: Icon(IconsaxPlusBold.share, size: size * 0.64, color: colors.onPrimary),
        ),
      ),
    );
  }
}
