import "dart:convert";
import "dart:typed_data";

import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/providers/browser/directory_provider.dart";
import "package:polder_core/providers/browser/file_operations_provider.dart";
import "package:polder_notes/providers/notes/last_note_provider.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_tag_filter_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder_notes/screens/notes/widgets/recipe_dialog.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder_core/services/offline/offline_files.dart";
import "package:polder_notes/services/notes/note_checklist.dart";
import "package:polder_notes/services/notes/note_recipe.dart";
import "package:polder_ui/util/action_feedback.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/util/unique_name.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/files/remote_folder_picker_dialog.dart";
import "package:polder_ui/widgets/shared/text_input_dialog.dart";

enum NewNoteKind {
  page,
  checklist;

  String title(AppLocalizations localized) => switch (this) {
    page => localized.noteNewPage,
    checklist => localized.noteNewChecklist,
  };

  String get content => switch (this) {
    page => "",
    checklist => NoteChecklist.empty,
  };
}

abstract final class NotesActions {
  static Future<void> createPage(
    BuildContext context, {
    required String folder,
    NewNoteKind kind = NewNoteKind.page,
  }) async {
    final localized = context.localized;
    final container = ProviderScope.containerOf(context, listen: false);
    final name = await showTextInputDialog(
      context,
      title: kind.title(localized),
      label: localized.name,
      confirmLabel: localized.create,
      isValid: (value) => RemotePath.isValidName(value.trim()),
    );
    if (name == null || !context.mounted) return;
    FileEntry? created;
    final succeeded = await context.runWithFeedback(
      Future(() async {
        created = await _createNote(container, folder: folder, name: name.trim(), content: kind.content);
        await _applyTagFilter(container, created!);
      }),
    );
    if (succeeded && created != null && context.mounted) context.go(notesLocationsOf(context).noteAt(created!.path));
  }

  static Future<void> createSubpage(BuildContext context, NoteTreeNode parent) =>
      createPage(context, folder: parent.childrenPath);

  static Future<void> createInNotesFolder(BuildContext context, {NewNoteKind kind = NewNoteKind.page}) async {
    final folder = await _notesFolder(context);
    if (folder != null && context.mounted) await createPage(context, folder: folder, kind: kind);
  }

  static Future<void> addRecipe(BuildContext context, {required String folder}) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final created = await showRecipeDialog(
      context,
      folder: folder,
      createCustom: (name) => _createNote(container, folder: folder, name: name, content: NoteRecipe.template),
    );
    if (created == null || !context.mounted) return;
    await context.runWithFeedback(_applyTagFilter(container, created));
    _refresh(container, folder);
    if (context.mounted) context.go(notesLocationsOf(context).noteAt(created.path));
  }

  static Future<void> _applyTagFilter(ProviderContainer container, FileEntry created) async {
    final tags = container.read(tagsByIdProvider);
    final view = container.read(notesTagFilterProvider);
    if (view is! TaggedNotes) return;
    final names = [for (final id in view.tagIds) ?tags[id]?.name];
    if (names.isEmpty) return;
    try {
      await container.read(tagsProvider.notifier).assign([created.path], names);
    } on ApiException {
      return;
    }
  }

  static Future<void> addRecipeInNotesFolder(BuildContext context) async {
    final folder = await _notesFolder(context);
    if (folder != null && context.mounted) await addRecipe(context, folder: folder);
  }

  static Future<String?> _notesFolder(BuildContext context) async {
    final folder = await ProviderScope.containerOf(context, listen: false).read(notesFolderProvider.future);
    if (folder != null || !context.mounted) return folder;
    return showNotesSetupDialog(context);
  }

  static Future<FileEntry> _createNote(
    ProviderContainer container, {
    required String folder,
    required String name,
    required String content,
  }) async {
    final api = container.read(polderApiProvider);
    final offline = await offlineFor(container.read(offlineFilesProvider.future), folder);
    final fileName = uniqueName(name, noteExtension, await namesIn(api, folder, offline: offline));
    final path = RemotePath.join(folder, fileName);
    final bytes = utf8.encode(content);
    final FileEntry created;
    if (offline != null) {
      created = (await offline.write(path, Uint8List.fromList(bytes))).entry;
      await container.read(offlineSyncProvider.notifier).pushNow();
    } else {
      created = await api.putContent(path, Stream.value(bytes), length: bytes.length);
    }
    _refresh(container, folder);
    return created;
  }

  static Future<OfflineFiles?> offlineFor(Future<OfflineFiles> files, String path) async {
    final offline = await files;
    return await offline.availableOffline(path) ? offline : null;
  }

  static Future<Set<String>> namesIn(PolderApi api, String folder, {OfflineFiles? offline}) async {
    if (offline != null) return {for (final file in await offline.children(folder)) file.entry.name};
    try {
      return {for (final entry in (await api.list(folder)).entries) entry.name};
    } on NotFoundException {
      return {};
    }
  }

  static Future<NoteTreeNode> nodeFor(PolderApi api, FileEntry page, {OfflineFiles? offline}) async {
    final node = NoteTreeNode(page: page);
    if (offline != null) {
      final folder = await offline.file(node.childrenPath);
      return NoteTreeNode(page: page, folder: folder != null && folder.isDir ? folder.entry : null);
    }
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

  static String _pageFileName(FileEntry page, String name) =>
      page.isMarkdown ? "$name.${RemotePath.extension(page.name)}" : name;

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
      _trackNodes(
        container,
        kind: FileOperationKind.move,
        nodes: nodes,
        destination: destination,
        perform: (node) async {
          await _moveNode(container, node, destination, node.name);
          moved[node] = _movedPath(node, destination, node.name);
        },
      ),
    );
    return moved;
  }

  static Future<Map<NoteTreeNode, String>> moveAll(BuildContext context, List<NoteTreeNode> nodes) async {
    final destination = await showRemoteFolderPicker(context, initialPath: RemotePath.parent(nodes.first.path));
    if (destination == null || !context.mounted) return const {};
    return moveAllInto(context, nodes, destination);
  }

  static String _movedPath(NoteTreeNode node, String destination, String name) =>
      RemotePath.join(destination, node.page == null ? name : _pageFileName(node.page!, name));

  static Future<String?> _moveWithFeedback(
    BuildContext context,
    NoteTreeNode node,
    String destination,
    String name,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final renaming = destination == RemotePath.parent(node.path);
    final moved = await context.runWithFeedback(
      _trackNodes(
        container,
        kind: renaming ? FileOperationKind.rename : FileOperationKind.move,
        nodes: [node],
        destination: renaming ? null : destination,
        targetName: (node) => RemotePath.name(_movedPath(node, destination, name)),
        perform: (node) => _moveNode(container, node, destination, name),
      ),
    );
    if (!moved) return null;
    return _movedPath(node, destination, name);
  }

  static Future<void> _trackNodes(
    ProviderContainer container, {
    required FileOperationKind kind,
    required List<NoteTreeNode> nodes,
    required Future<void> Function(NoteTreeNode node) perform,
    String? destination,
    String Function(NoteTreeNode node)? targetName,
  }) {
    final byPath = {for (final node in nodes) node.path: node};
    return container
        .read(fileOperationsProvider.notifier)
        .run(
          kind: kind,
          destination: destination,
          items: [
            for (final node in byPath.values)
              FileOperationItem(
                path: node.path,
                isDir: node.page == null,
                label: node.name,
                targetName: targetName?.call(node),
              ),
          ],
          perform: (item) => perform(byPath[item.path]!),
        );
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
    final offline = await offlineFor(container.read(offlineFilesProvider.future), node.path);
    if (offline != null && await offline.availableOffline(destination)) {
      if (node.page case final page?) {
        await offline.move(page.path, RemotePath.join(destination, _pageFileName(page, name)));
      }
      if (node.folder case final folder?) await offline.move(folder.path, RemotePath.join(destination, name));
    } else {
      final api = container.read(polderApiProvider);
      final page = node.page;
      if (page != null) {
        await api.move(from: page.path, to: RemotePath.join(destination, _pageFileName(page, name)), baseRev: page.rev);
      }
      final folder = node.folder;
      if (folder != null) await api.move(from: folder.path, to: RemotePath.join(destination, name));
    }
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
    final container = ProviderScope.containerOf(context, listen: false);
    return context.runWithFeedback(
      _trackNodes(
        container,
        kind: FileOperationKind.delete,
        nodes: [node],
        perform: (node) => _deleteNode(container, node),
      ),
    );
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
      _trackNodes(
        container,
        kind: FileOperationKind.delete,
        nodes: nodes,
        perform: (node) => _deleteNode(container, node),
      ),
    );
  }

  static Future<void> _deleteNode(ProviderContainer container, NoteTreeNode node) async {
    final offline = await offlineFor(container.read(offlineFilesProvider.future), node.path);
    if (offline != null) {
      if (node.folder case final folder?) await offline.delete(folder.path);
      if (node.page case final page?) await offline.delete(page.path);
    } else {
      final api = container.read(polderApiProvider);
      if (node.folder case final folder?) await api.delete(folder.path);
      if (node.page case final page?) await api.delete(page.path);
    }
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
