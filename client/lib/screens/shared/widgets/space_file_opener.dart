import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/screens/shared/widgets/space_directory_view.dart";
import "package:polder/screens/viewer/document_editor_screen.dart";
import "package:polder/screens/viewer/media/media_viewer_screen.dart";
import "package:polder/screens/viewer/pdf_viewer_screen.dart";
import "package:polder/screens/viewer/shared_note_screen.dart";

bool hasSpaceViewer(FileEntry entry, EditorCapabilities editor) => _hasBuiltInViewer(entry) || editor.canOpen(entry);

bool _hasBuiltInViewer(FileEntry entry) => entry.isMarkdown || entry.isPdf || entry.isViewableMedia;

Future<void> openSpaceEntry(
  BuildContext context,
  FileSpace space,
  FileEntry entry, {
  List<FileEntry> siblings = const [],
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final viewable =
      container.read(spaceCapabilitiesProvider(space)).canDownload &&
      (_hasBuiltInViewer(entry) || await _editorOpens(container, space, entry));
  if (!context.mounted) return;
  if (!viewable) return showSpaceFileSheet(context, space, entry);
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _viewer(space, entry, siblings)));
}

Future<bool> _editorOpens(ProviderContainer container, FileSpace space, FileEntry entry) async {
  final editor = await container
      .read(spaceEditorCapabilitiesProvider(space).future)
      .catchError((Object _) => const EditorCapabilities());
  return editor.canOpen(entry);
}

Widget _viewer(FileSpace space, FileEntry entry, List<FileEntry> siblings) {
  if (entry.isMarkdown) return SharedNoteScreen(space: space, entry: entry);
  if (entry.isPdf) return PdfViewerScreen(entry: entry, space: space);
  if (entry.isViewableMedia) {
    final media = [
      for (final sibling in siblings)
        if (sibling.isViewableMedia) sibling,
    ];
    final gallery = media.any((item) => item.path == entry.path) ? media : [entry];
    return MediaViewerScreen(entry: entry, gallery: gallery, space: space);
  }
  return DocumentEditorScreen(target: EditorTarget(entry, space: space));
}
