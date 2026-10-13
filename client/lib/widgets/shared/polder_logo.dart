import "dart:ui" as ui;

import "package:flutter/material.dart";

import "package:flutter_svg/flutter_svg.dart";
import "package:polder/util/flavor.dart";
import "package:polder/util/localization_helper.dart";

const _polderSvg = SvgAssetLoader("assets/icon/polder.svg");

Future<void> precachePolderIcon() => svg.cache.putIfAbsent(_polderSvg.cacheKey(null), () => _polderSvg.loadBytes(null));

class PolderIcon extends StatelessWidget {
  const PolderIcon({this.size = 100, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = isDevFlavor ? const [devFlavorOrange, devFlavorOrange] : [cs.primary, cs.secondary];
    return ShaderMask(
      shaderCallback: (bounds) => ui.Gradient.linear(bounds.topLeft, bounds.bottomRight, colors),
      child: SvgPicture(
        _polderSvg,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class PolderLogo extends StatelessWidget {
  const PolderLogo({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    runAlignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 16,
    runSpacing: 8,
    children: [
      const PolderIcon(),
      Text(context.localized.appTitle, style: Theme.of(context).textTheme.displayLarge, textAlign: TextAlign.center),
    ],
  );
}
