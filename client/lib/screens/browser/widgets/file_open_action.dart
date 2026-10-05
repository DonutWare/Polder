import "package:flutter/material.dart";

import "package:go_router/go_router.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_details_sheet.dart";

void openEntry(BuildContext context, FileEntry entry) {
  if (entry.isDir) return context.go(AppRoutes.filesAt(entry.path));
  if (entry.isPdf) {
    context.push(AppRoutes.pdf, extra: entry);
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => FileDetailsSheet(entry: entry),
  );
}
