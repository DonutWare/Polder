import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:media_viewer/media_viewer.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/file_content_provider.dart";
import "package:polder/providers/browser/thumbnail_provider.dart";
import "package:polder/screens/viewer/media/media_chrome.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/loading_indicator.dart";

class MediaPhotoPage extends ConsumerStatefulWidget {
  const MediaPhotoPage({required this.entry, required this.page, super.key});

  final FileEntry entry;
  final MediaPage page;

  @override
  ConsumerState<MediaPhotoPage> createState() => _MediaPhotoPageState();
}

class _MediaPhotoPageState extends ConsumerState<MediaPhotoPage> {
  Size? _contentSize;
  ImageStream? _sizeStream;
  Uint8List? _measuredBytes;
  late final _sizeListener = ImageStreamListener((info, _) {
    final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
    info.dispose();
    if (mounted && size != _contentSize) setState(() => _contentSize = size);
  });

  bool get _isSvg => widget.entry.mime == "image/svg+xml";

  @override
  void dispose() {
    _sizeStream?.removeListener(_sizeListener);
    super.dispose();
  }

  void _measure(Uint8List bytes) {
    if (identical(bytes, _measuredBytes)) return;
    _measuredBytes = bytes;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(bytes, _measuredBytes)) return;
      _sizeStream?.removeListener(_sizeListener);
      _sizeStream = MemoryImage(bytes).resolve(ImageConfiguration.empty)..addListener(_sizeListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    final poster = ref.watch(thumbnailProvider(mediaPoster(widget.entry))).value;
    final original = ref.watch(fileContentProvider(widget.entry));
    final originalBytes = original.value;
    final measurable = _isSvg ? null : originalBytes ?? poster;
    if (measurable != null) _measure(measurable);
    return Stack(
      fit: StackFit.expand,
      children: [
        ZoomableMedia(
          active: widget.page.active,
          contentSize: _contentSize,
          onTap: widget.page.onTap,
          onZoomChanged: widget.page.onZoomChanged,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (poster != null) Image.memory(poster, fit: BoxFit.contain, gaplessPlayback: true),
              if (originalBytes != null) _original(originalBytes),
            ],
          ),
        ),
        if (original.isLoading && poster == null) const LoadingIndicator(),
        if (original.hasError && originalBytes == null)
          Align(
            alignment: poster == null ? Alignment.center : const Alignment(0, 0.6),
            child: MediaFailure(
              compact: poster != null,
              onRetry: () => ref.invalidate(fileContentProvider(widget.entry)),
            ),
          ),
      ],
    );
  }

  Widget _original(Uint8List bytes) {
    if (_isSvg) return SvgPicture.memory(bytes, fit: BoxFit.contain);
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, synchronous) => AnimatedOpacity(
        opacity: synchronous || frame != null ? 1 : 0,
        duration: AppMotion.effectsDuration,
        curve: AppMotion.effects,
        child: child,
      ),
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
