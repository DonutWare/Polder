import "package:flutter/material.dart";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:polder/models/branding.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/theme/app_theme.dart";

class ServerIcon extends ConsumerWidget {
  const ServerIcon({required this.size, required this.fallback, super.key});

  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingProvider);
    final icon = branding.icon;
    final url = branding.iconUrl;
    if (icon == null || url == null) return fallback;
    return SizedBox.square(
      dimension: size,
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(size * AppRadius.inset / 64),
        child: ServerImageView(url: url, image: icon, fit: BoxFit.contain, fallback: fallback),
      ),
    );
  }
}

class ServerImageView extends StatelessWidget {
  const ServerImageView({
    required this.url,
    required this.image,
    required this.fit,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });

  final String url;
  final ServerImage image;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => image.isSvg
      ? SvgPicture.network(url, fit: fit, placeholderBuilder: (_) => fallback, errorBuilder: (_, _, _) => fallback)
      : CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          fadeInDuration: Duration.zero,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        );
}
