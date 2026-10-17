import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/models/file_version.dart";
import "package:polder/models/thumbnail_request.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/browser/thumbnail_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/theme/app_theme.dart";

class FileThumbnail extends StatelessWidget {
  FileThumbnail({required FileEntry entry, required this.dimension, this.fill = false, super.key})
    : isDir = entry.isDir,
      mime = entry.mime,
      hasPreview = entry.hasPreview,
      preview = ((size) => thumbnailProvider(ThumbnailRequest.file(path: entry.path, rev: entry.rev, size: size)));

  FileThumbnail.inSpace({
    required FileSpace space,
    required FileEntry entry,
    required this.dimension,
    this.fill = false,
    super.key,
  }) : isDir = entry.isDir,
       mime = entry.mime,
       hasPreview = entry.hasPreview,
       preview = ((size) => spaceThumbnailProvider((SpaceLocation(space: space, path: entry.path), size)));

  FileThumbnail.trashed({required TrashItem item, required this.dimension, this.fill = false, super.key})
    : isDir = item.isDir,
      mime = item.mime,
      hasPreview = item.hasPreview,
      preview = ((size) => thumbnailProvider(ThumbnailRequest.trash(itemId: item.id, size: size)));

  FileThumbnail.version({
    required FileEntry entry,
    required FileVersion version,
    required this.dimension,
    this.fill = false,
    super.key,
  }) : isDir = false,
       mime = entry.mime,
       hasPreview = version.hasPreview,
       preview = ((size) => thumbnailProvider(ThumbnailRequest.version(versionId: version.id, size: size)));

  final bool isDir;
  final String mime;
  final bool hasPreview;
  final ProviderListenable<AsyncValue<Uint8List?>> Function(int size) preview;
  final double dimension;

  final bool fill;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: Center(
      child: hasPreview
          ? _PreviewImage(thumbnail: this)
          : FileTypeIcon.of(isDir: isDir, mime: mime, size: fill ? dimension * 0.45 : dimension),
    ),
  );
}

class _PreviewImage extends ConsumerWidget {
  const _PreviewImage({required this.thumbnail});

  final FileThumbnail thumbnail;

  double get _dimension => thumbnail.dimension;

  int get _requestSize => _dimension <= 64 ? 128 : (_dimension <= 192 ? 256 : 512);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(thumbnail.preview(_requestSize)).value;
    if (bytes == null) {
      return FileTypeIcon.of(
        isDir: thumbnail.isDir,
        mime: thumbnail.mime,
        size: _dimension <= 64 ? _dimension : _dimension * 0.45,
      );
    }
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(_dimension <= 64 ? _dimension * 0.34 : AppRadius.inset),
      child: Image.memory(bytes, width: _dimension, height: _dimension, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}
