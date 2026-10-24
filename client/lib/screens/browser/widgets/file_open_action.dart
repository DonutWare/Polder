import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/browser_scope.dart";
import "package:polder/screens/browser/widgets/file_details_sheet.dart";

Future<void> openEntry(BuildContext context, FileEntry entry) async {
  if (entry.isDir) return context.go(BrowserRoutes.of(context).routeFor(entry.path));
  if (entry.isMarkdown) return context.go(AppRoutes.noteAt(entry.path));
  if (entry.isPdf) {
    await context.push(AppRoutes.pdf, extra: entry);
    return;
  }
  if (await _editorCanEdit(context, entry)) {
    if (context.mounted) await context.push(AppRoutes.editor, extra: entry);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
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
