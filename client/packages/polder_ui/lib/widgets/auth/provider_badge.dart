import "package:flutter/material.dart";

import "package:flutter_svg/flutter_svg.dart";
import "package:iconsax_plus/iconsax_plus.dart";

class ProviderBadge extends StatelessWidget {
  const ProviderBadge({required this.preset, required this.label, this.size = 22, super.key});

  final String preset;
  final String label;
  final double size;

  static const _logos = {"pocket-id", "authentik", "authelia", "keycloak", "google", "microsoft", "github"};
  static const _followsTextColor = {"github"};

  @override
  Widget build(BuildContext context) {
    if (!_logos.contains(preset)) return Icon(IconsaxPlusLinear.key, size: size);
    return SvgPicture.asset(
      "assets/icons/sso/$preset.svg",
      package: "polder_ui",
      width: size,
      height: size,
      semanticsLabel: label,
      colorFilter: _followsTextColor.contains(preset)
          ? ColorFilter.mode(IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)
          : null,
    );
  }
}
