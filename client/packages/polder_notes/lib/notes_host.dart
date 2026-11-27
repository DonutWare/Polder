import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_version.dart";

typedef FileOpener = Future<void> Function(BuildContext context, FileEntry entry, {List<FileEntry>? gallery});

typedef FileRevealer = void Function(BuildContext context, FileEntry entry);

typedef FileHistoryViewer = Future<void> Function(
  BuildContext context,
  FileEntry entry, {
  required void Function(FileVersion version) onView,
  required Future<void> Function(FileVersion version) onRestore,
});

typedef FileSearchBuilder = Widget Function(BuildContext context, ValueChanged<FileEntry> onPick);

typedef FileThumbnailBuilder = Widget Function(FileEntry entry, double dimension);

class NotesHost {
  const NotesHost({
    required this.openFile,
    this.showInFiles,
    this.showFileHistory,
    this.fileSearch,
    this.fileThumbnail,
  });

  final FileOpener openFile;
  final FileRevealer? showInFiles;
  final FileHistoryViewer? showFileHistory;
  final FileSearchBuilder? fileSearch;
  final FileThumbnailBuilder? fileThumbnail;
}

final notesHostProvider = Provider<NotesHost>(
  (ref) => throw UnimplementedError("Each app overrides notesHostProvider"),
);

NotesHost notesHostOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(notesHostProvider);
