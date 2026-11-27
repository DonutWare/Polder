import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/models/document_editor.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/media_gallery.dart";
import "package:polder_drive/providers/browser/editor_capabilities_provider.dart";
import "package:polder_drive/drive_host.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/screens/browser/widgets/browser_scope.dart";
import "package:polder_drive/screens/browser/widgets/file_details_sheet.dart";

Future<void> openEntry(BuildContext context, FileEntry entry, {List<FileEntry>? gallery}) async {
  if (entry.isDir) return context.go(BrowserRoutes.of(context).routeFor(entry.path));
  if (entry.isText) {
    if (driveHostOf(context).openNote case final openNote?) return openNote(context, entry.path);
  }
  if (entry.isPdf) {
    await context.push(DriveRoutes.pdf, extra: entry);
    return;
  }
  if (entry.isViewableMedia) {
    await context.push(DriveRoutes.media, extra: gallery == null ? entry : MediaGallery(entry, gallery));
    return;
  }
  if (await _editorCanEdit(context, entry)) {
    if (context.mounted) await context.push(DriveRoutes.editor, extra: entry);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (_) => FileDetailsSheet(entry: entry),
  );
}

Future<bool> _editorCanEdit(BuildContext context, FileEntry entry) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final editor = await container
      .read(editorCapabilitiesProvider.future)
      .catchError((Object _) => const EditorCapabilities());
  if (!editor.enabled) container.invalidate(editorCapabilitiesProvider);
  return editor.canEdit(entry);
}
