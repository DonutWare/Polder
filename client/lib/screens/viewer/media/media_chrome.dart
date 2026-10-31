import "dart:ui";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/thumbnail_request.dart";
import "package:polder/providers/appearance/appearance_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/message_view.dart";

const _posterSize = 512;

ThumbnailRequest mediaPoster(FileEntry entry) =>
    ThumbnailRequest.file(path: entry.path, rev: entry.rev, size: _posterSize);

class MediaViewerTheme extends ConsumerWidget {
  const MediaViewerTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(appearanceProvider).seedWith(ref.watch(brandingProvider).accent);
    return Theme(data: AppTheme.build(seed, Brightness.dark), child: child);
  }
}

class FloatingPanel extends StatelessWidget {
  const FloatingPanel({
    required this.child,
    this.radius = AppRadius.panel,
    this.padding = const EdgeInsets.all(6),
    super.key,
  });

  static const _blur = 24.0;
  static const _opacity = 0.82;

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shape = squircle(radius, side: BorderSide(color: colors.border));
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: colors.panel.withValues(alpha: _opacity),
            shape: shape,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class MediaPlayBadge extends StatelessWidget {
  const MediaPlayBadge({super.key});

  static const _size = 76.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.92),
        shape: AppShapes.cookie,
        shadows: const [BoxShadow(color: Colors.black38, blurRadius: 24)],
      ),
      child: SizedBox.square(
        dimension: _size,
        child: Icon(IconsaxPlusBold.play, size: _size * 0.42, color: colors.onPrimaryContainer),
      ),
    );
  }
}

class MediaFailure extends StatelessWidget {
  const MediaFailure({required this.onRetry, this.detail, this.compact = false, super.key});

  final VoidCallback onRetry;
  final String? detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final retry = FilledButton.tonalIcon(
      icon: const Icon(IconsaxPlusLinear.refresh),
      label: Text(localized.retry),
      onPressed: onRetry,
    );
    if (compact) {
      return FloatingPanel(
        padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(IconsaxPlusLinear.gallery_slash, color: Theme.of(context).colorScheme.error),
            Flexible(child: Text(localized.couldNotLoadMedia)),
            retry,
          ],
        ),
      );
    }
    return MessageView(
      icon: IconsaxPlusLinear.gallery_slash,
      color: Theme.of(context).colorScheme.error,
      message: detail == null ? localized.couldNotLoadMedia : "${localized.couldNotLoadMedia}\n$detail",
      action: retry,
    );
  }
}
