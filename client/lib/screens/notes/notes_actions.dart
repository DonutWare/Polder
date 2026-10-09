import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/unique_name.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

abstract final class NotesActions {
  static Future<void> createPage(BuildContext context, WidgetRef ref, {required String folder}) async {
    final localized = context.localized;
    final name = await showTextInputDialog(
      context,
      title: localized.noteNewPage,
      label: localized.name,
      confirmLabel: localized.create,
      isValid: (value) => RemotePath.isValidName(value.trim()),
    );
    if (name == null || !context.mounted) return;
    FileEntry? created;
    final succeeded = await context.runWithFeedback(
      Future(() async => created = await _createNote(ref, folder: folder, name: name.trim())),
    );
    if (succeeded && created != null && context.mounted) context.go(AppRoutes.noteAt(created!.path));
  }

  static Future<void> createSubpage(BuildContext context, WidgetRef ref, NoteTreeNode parent) =>
      createPage(context, ref, folder: parent.childrenPath);

  static Future<void> createInNotesFolder(BuildContext context, WidgetRef ref) async {
    var folder = await ref.read(notesFolderProvider.future);
    if (!context.mounted) return;
    folder ??= await showNotesSetupDialog(context);
    if (folder != null && context.mounted) await createPage(context, ref, folder: folder);
  }

  static Future<FileEntry> _createNote(WidgetRef ref, {required String folder, required String name}) async {
    final api = ref.read(polderApiProvider);
    final fileName = uniqueName(name, noteExtension, await namesIn(api, folder));
    final created = await api.putContent(RemotePath.join(folder, fileName), const Stream.empty(), length: 0);
    _refresh(ref, folder);
    return created;
  }

  static Future<Set<String>> namesIn(PolderApi api, String folder) async {
    try {
      return {for (final entry in (await api.list(folder)).entries) entry.name};
    } on NotFoundException {
      return {};
    }
  }

  static Future<NoteTreeNode> nodeFor(WidgetRef ref, FileEntry page) async {
    final node = NoteTreeNode(page: page);
    try {
      final folder = await ref.read(polderApiProvider).stat(node.childrenPath);
      return NoteTreeNode(page: page, folder: folder.isDir ? folder : null);
    } on NotFoundException {
      return node;
    }
  }

  static Future<String?> rename(BuildContext context, WidgetRef ref, NoteTreeNode node) async {
    final localized = context.localized;
    final current = node.name;
    final name = await showTextInputDialog(
      context,
      title: localized.rename,
      label: localized.name,
      initialValue: current,
      confirmLabel: localized.rename,
      isValid: (value) => RemotePath.isValidName(value.trim()) && value.trim() != current,
    );
    if (name == null || !context.mounted) return null;
    final parent = RemotePath.parent(node.path);
    return _moveWithFeedback(context, ref, node, parent, name.trim());
  }

  static String _extension(FileEntry page) => page.name.substring(page.name.lastIndexOf(".") + 1);

  static Future<String?> move(BuildContext context, WidgetRef ref, NoteTreeNode node) async {
    final destination = await showRemoteFolderPicker(context, initialPath: RemotePath.parent(node.path));
    if (destination == null || destination == RemotePath.parent(node.path) || !context.mounted) return null;
    return _moveWithFeedback(context, ref, node, destination, node.name);
  }

  static Future<String?> _moveWithFeedback(
    BuildContext context,
    WidgetRef ref,
    NoteTreeNode node,
    String destination,
    String name,
  ) async {
    final moved = await context.runWithFeedback(_moveNode(ref, node, destination, name));
    if (!moved) return null;
    return RemotePath.join(destination, node.page == null ? name : "$name.${_extension(node.page!)}");
  }

  static String? pathAfterMove(String? path, NoteTreeNode node, String movedTo) {
    if (path == null) return null;
    if (path == node.page?.path) return movedTo;
    final folder = node.childrenPath;
    if (!RemotePath.isWithin(path, folder)) return null;
    final movedFolder = node.page == null
        ? movedTo
        : RemotePath.join(RemotePath.parent(movedTo), RemotePath.withoutExtension(RemotePath.name(movedTo)));
    return movedFolder + path.substring(folder.length);
  }

  static Future<void> _moveNode(WidgetRef ref, NoteTreeNode node, String destination, String name) async {
    final api = ref.read(polderApiProvider);
    final page = node.page;
    if (page != null) {
      await api.move(from: page.path, to: RemotePath.join(destination, "$name.${_extension(page)}"), baseRev: page.rev);
    }
    final folder = node.folder;
    if (folder != null) await api.move(from: folder.path, to: RemotePath.join(destination, name));
    _refresh(ref, RemotePath.parent(node.path));
    _refresh(ref, destination);
  }

  static Future<bool> delete(BuildContext context, WidgetRef ref, NoteTreeNode node) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.noteDeleteTitle(node.name),
      message: node.hasChildren ? localized.noteDeleteWithChildrenMessage : localized.noteDeleteMessage,
      confirmLabel: localized.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;
    final api = ref.read(polderApiProvider);
    return context.runWithFeedback(
      Future(() async {
        if (node.page case final page?) await api.delete(page.path, baseRev: page.rev);
        if (node.folder case final folder?) await api.delete(folder.path);
        _refresh(ref, RemotePath.parent(node.path));
      }),
    );
  }

  static void _refresh(WidgetRef ref, String folder) {
    ref.invalidate(notesTreeProvider);
    ref.invalidate(directoryProvider(folder));
  }
}
