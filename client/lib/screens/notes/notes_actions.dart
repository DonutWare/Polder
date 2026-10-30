import "dart:convert";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/last_note_provider.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_checklist.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/unique_name.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

abstract final class NotesActions {
  static Future<void> createPage(BuildContext context, {required String folder, bool checklist = false}) async {
    final localized = context.localized;
    final container = ProviderScope.containerOf(context, listen: false);
    final name = await showTextInputDialog(
      context,
      title: checklist ? localized.noteNewChecklist : localized.noteNewPage,
      label: localized.name,
      confirmLabel: localized.create,
      isValid: (value) => RemotePath.isValidName(value.trim()),
    );
    if (name == null || !context.mounted) return;
    FileEntry? created;
    final succeeded = await context.runWithFeedback(
      Future(
        () async => created = await _createNote(
          container,
          folder: folder,
          name: name.trim(),
          content: checklist ? NoteChecklist.empty : "",
        ),
      ),
    );
    if (succeeded && created != null && context.mounted) context.go(AppRoutes.noteAt(created!.path));
  }

  static Future<void> createSubpage(BuildContext context, NoteTreeNode parent) =>
      createPage(context, folder: parent.childrenPath);

  static Future<void> createInNotesFolder(BuildContext context, {bool checklist = false}) async {
    var folder = await ProviderScope.containerOf(context, listen: false).read(notesFolderProvider.future);
    if (!context.mounted) return;
    folder ??= await showNotesSetupDialog(context);
    if (folder != null && context.mounted) await createPage(context, folder: folder, checklist: checklist);
  }

  static Future<FileEntry> _createNote(
    ProviderContainer container, {
    required String folder,
    required String name,
    required String content,
  }) async {
    final api = container.read(polderApiProvider);
    final fileName = uniqueName(name, noteExtension, await namesIn(api, folder));
    final bytes = utf8.encode(content);
    final created = await api.putContent(RemotePath.join(folder, fileName), Stream.value(bytes), length: bytes.length);
    _refresh(container, folder);
    return created;
  }

  static Future<Set<String>> namesIn(PolderApi api, String folder) async {
    try {
      return {for (final entry in (await api.list(folder)).entries) entry.name};
    } on NotFoundException {
      return {};
    }
  }

  static Future<NoteTreeNode> nodeFor(PolderApi api, FileEntry page) async {
    final node = NoteTreeNode(page: page);
    try {
      final folder = await api.stat(node.childrenPath);
      return NoteTreeNode(page: page, folder: folder.isDir ? folder : null);
    } on NotFoundException {
      return node;
    }
  }

  static Future<String?> rename(BuildContext context, NoteTreeNode node) async {
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
    return _moveWithFeedback(context, node, parent, name.trim());
  }

  static String _extension(FileEntry page) => page.name.substring(page.name.lastIndexOf(".") + 1);

  static Future<String?> move(BuildContext context, NoteTreeNode node) async {
    final destination = await showRemoteFolderPicker(context, initialPath: RemotePath.parent(node.path));
    if (destination == null || destination == RemotePath.parent(node.path) || !context.mounted) return null;
    return _moveWithFeedback(context, node, destination, node.name);
  }

  static bool canMoveInto(NoteTreeNode node, String destination) =>
      destination != RemotePath.parent(node.path) &&
      destination != node.childrenPath &&
      destination != node.path &&
      !RemotePath.isWithin(destination, node.childrenPath);

  static bool canMoveAllInto(List<NoteTreeNode> nodes, String destination) =>
      nodes.isNotEmpty && nodes.every((node) => canMoveInto(node, destination));

  static Future<Map<NoteTreeNode, String>> moveAllInto(
    BuildContext context,
    List<NoteTreeNode> nodes,
    String destination,
  ) async {
    final moved = <NoteTreeNode, String>{};
    if (!canMoveAllInto(nodes, destination)) return moved;
    final container = ProviderScope.containerOf(context, listen: false);
    await context.runWithFeedback(
      Future(() async {
        for (final node in nodes) {
          await _moveNode(container, node, destination, node.name);
          moved[node] = _movedPath(node, destination, node.name);
        }
      }),
    );
    return moved;
  }

  static Future<Map<NoteTreeNode, String>> moveAll(BuildContext context, List<NoteTreeNode> nodes) async {
    final destination = await showRemoteFolderPicker(context, initialPath: RemotePath.parent(nodes.first.path));
    if (destination == null || !context.mounted) return const {};
    return moveAllInto(context, nodes, destination);
  }

  static String _movedPath(NoteTreeNode node, String destination, String name) =>
      RemotePath.join(destination, node.page == null ? name : "$name.${_extension(node.page!)}");

  static Future<String?> _moveWithFeedback(
    BuildContext context,
    NoteTreeNode node,
    String destination,
    String name,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final moved = await context.runWithFeedback(_moveNode(container, node, destination, name));
    if (!moved) return null;
    return _movedPath(node, destination, name);
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

  static Future<void> _moveNode(ProviderContainer container, NoteTreeNode node, String destination, String name) async {
    final api = container.read(polderApiProvider);
    final page = node.page;
    if (page != null) {
      await api.move(from: page.path, to: RemotePath.join(destination, "$name.${_extension(page)}"), baseRev: page.rev);
    }
    final folder = node.folder;
    if (folder != null) await api.move(from: folder.path, to: RemotePath.join(destination, name));
    _refresh(container, RemotePath.parent(node.path));
    _refresh(container, destination);
  }

  static Future<bool> delete(BuildContext context, NoteTreeNode node) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.noteDeleteTitle(node.name),
      message: node.hasChildren ? localized.noteDeleteWithChildrenMessage : localized.noteDeleteMessage,
      confirmLabel: localized.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;
    return context.runWithFeedback(_deleteNode(ProviderScope.containerOf(context, listen: false), node));
  }

  static Future<bool> deleteAll(BuildContext context, List<NoteTreeNode> nodes) async {
    if (nodes.length == 1) return delete(context, nodes.single);
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.noteDeleteManyTitle(nodes.length),
      message: localized.noteDeleteManyMessage,
      confirmLabel: localized.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;
    final container = ProviderScope.containerOf(context, listen: false);
    return context.runWithFeedback(
      Future(() async {
        for (final node in nodes) {
          await _deleteNode(container, node);
        }
      }),
    );
  }

  static Future<void> _deleteNode(ProviderContainer container, NoteTreeNode node) async {
    final api = container.read(polderApiProvider);
    if (node.folder case final folder?) await api.delete(folder.path);
    if (node.page case final page?) await api.delete(page.path);
    _forgetLastNoteIn(container, node);
    _refresh(container, RemotePath.parent(node.path));
  }

  static void _forgetLastNoteIn(ProviderContainer container, NoteTreeNode node) {
    final last = container.read(lastNoteProvider);
    if (last != null && node.holds(last)) container.read(lastNoteProvider.notifier).set(null);
  }

  static void _refresh(ProviderContainer container, String folder) {
    container.invalidate(notesTreeProvider);
    container.invalidate(directoryProvider(folder));
  }
}
