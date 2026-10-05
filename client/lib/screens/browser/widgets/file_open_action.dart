import "package:flutter/material.dart";

import "package:go_router/go_router.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/routes/app_routes.dart";
import "package:nomad/screens/browser/widgets/file_details_sheet.dart";

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
