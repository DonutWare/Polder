import "package:flutter/material.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_space.dart";
import "package:polder/providers/browser/media_siblings_provider.dart";
import "package:polder/screens/viewer/media/media_info_panel.dart";
import "package:polder_media/media_viewer_screen.dart";

class PolderMediaViewer extends StatelessWidget {
  const PolderMediaViewer({required this.entry, this.gallery, this.space, super.key});

  final FileEntry entry;
  final List<FileEntry>? gallery;
  final FileSpace? space;

  @override
  Widget build(BuildContext context) => MediaViewerScreen(
    entry: entry,
    gallery: gallery,
    space: space,
    siblings: mediaSiblingsProvider.call,
    infoBuilder: (context, request) => MediaInfoPanel(
      entry: request.entry,
      asSheet: request.asSheet,
      onClose: request.onClose,
      onRenamed: request.onRenamed,
      onRemoved: request.onRemoved,
      space: space,
    ),
  );
}
