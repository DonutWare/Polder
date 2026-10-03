import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:nomad/models/file_entry.dart";
import "package:nomad/models/thumbnail_request.dart";
import "package:nomad/providers/browser/thumbnail_provider.dart";
import "package:nomad/screens/browser/widgets/file_type_icon.dart";
import "package:nomad/theme/app_theme.dart";

class FileThumbnail extends StatelessWidget {
  const FileThumbnail({required this.entry, required this.dimension, this.fill = false, super.key});

  final FileEntry entry;
  final double dimension;

  final bool fill;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: Center(
      child: entry.hasPreview
          ? _PreviewImage(entry: entry, dimension: dimension)
          : FileTypeIcon(entry: entry, size: fill ? dimension * 0.45 : dimension),
    ),
  );
}

class _PreviewImage extends ConsumerWidget {
  const _PreviewImage({required this.entry, required this.dimension});

  final FileEntry entry;
  final double dimension;

  int get _requestSize => dimension <= 64 ? 128 : (dimension <= 192 ? 256 : 512);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(
      thumbnailProvider(ThumbnailRequest(path: entry.path, rev: entry.rev, size: _requestSize)),
    );
    final bytes = preview.value;
    if (bytes == null) return FileTypeIcon(entry: entry, size: dimension <= 64 ? dimension : dimension * 0.45);
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(dimension <= 64 ? dimension * 0.34 : AppRadius.inset),
      child: Image.memory(bytes, width: dimension, height: dimension, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}
