import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/scan_session.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/editor_capabilities_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/scan/scan_review_screen.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/unique_name.dart";
import "package:polder/widgets/shared/fab_menu.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

class BrowserAddButton extends ConsumerWidget {
  const BrowserAddButton({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canScan = ref.watch(documentScannerServiceProvider).isSupported;
    final editor = ref.watch(editorCapabilitiesProvider).value ?? const EditorCapabilities();
    return FabMenu(
      icon: IconsaxPlusLinear.add,
      tooltip: context.localized.add,
      groups: [
        [
          FabMenuItem(
            icon: IconsaxPlusLinear.document_upload,
            label: context.localized.uploadFiles,
            onPressed: () => ref.read(transfersProvider.notifier).pickAndUpload(path),
          ),
          if (canScan)
            FabMenuItem(
              icon: IconsaxPlusLinear.scan,
              label: context.localized.scanDocument,
              onPressed: () => _scan(context, ref),
            ),
          FabMenuItem(
            icon: IconsaxPlusLinear.folder_add,
            label: context.localized.newFolder,
            onPressed: () => _createFolder(context, ref),
          ),
        ],
        [
          FabMenuItem(
            icon: IconsaxPlusLinear.note_2,
            label: context.localized.noteNewNote,
            onPressed: () => _createNote(context, ref),
          ),
          for (final kind in NewDocumentKind.values)
            if (editor.extensionsFor(kind).isNotEmpty)
              FabMenuItem(
                icon: _icon(kind),
                label: _label(context, kind),
                onPressed: () => _createDocument(context, ref, kind, editor),
              ),
        ],
      ],
    );
  }

  static IconData _icon(NewDocumentKind kind) => switch (kind) {
    NewDocumentKind.document => IconsaxPlusLinear.document_text,
    NewDocumentKind.spreadsheet => IconsaxPlusLinear.grid_5,
    NewDocumentKind.presentation => IconsaxPlusLinear.presention_chart,
    NewDocumentKind.pdf => IconsaxPlusLinear.document_1,
  };

  static String _label(BuildContext context, NewDocumentKind kind) => switch (kind) {
    NewDocumentKind.document => context.localized.documentKind,
    NewDocumentKind.spreadsheet => context.localized.spreadsheetKind,
    NewDocumentKind.presentation => context.localized.presentationKind,
    NewDocumentKind.pdf => context.localized.pdfKind,
  };

  static String _title(BuildContext context, NewDocumentKind kind) => switch (kind) {
    NewDocumentKind.document => context.localized.newDocument,
    NewDocumentKind.spreadsheet => context.localized.newSpreadsheet,
    NewDocumentKind.presentation => context.localized.newPresentation,
    NewDocumentKind.pdf => context.localized.newPdf,
  };

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final pages = await scanDocument(context, ref);
    if (pages != null && context.mounted) {
      await context.push(
        AppRoutes.scan,
        extra: ScanRequest(directory: path, pages: pages),
      );
    }
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final name = await showTextInputDialog(
      context,
      title: context.localized.newFolder,
      label: context.localized.name,
      confirmLabel: context.localized.create,
      isValid: (value) => RemotePath.isValidName(value.trim()),
    );
    if (name != null && context.mounted) {
      await context.runWithFeedback(ref.read(directoryProvider(path).notifier).createFolder(name));
    }
  }

  // The editor opens an empty file as a new document in the format its extension names, so the name
  // decides the format: any extension the editor can start a file in is accepted.
  Future<void> _createDocument(
    BuildContext context,
    WidgetRef ref,
    NewDocumentKind kind,
    EditorCapabilities editor,
  ) async {
    final creatable = {for (final extensions in editor.creatable.values) ...extensions};
    final taken = {for (final entry in ref.read(directoryProvider(path)).value?.entries ?? <FileEntry>[]) entry.name};
    final name = await showTextInputDialog(
      context,
      title: _title(context, kind),
      label: context.localized.name,
      confirmLabel: context.localized.create,
      initialValue: uniqueName(_label(context, kind), kind.defaultExtension(editor.extensionsFor(kind)), taken),
      isValid: (value) {
        final name = value.trim();
        return RemotePath.isValidName(name) && creatable.contains(_extension(name));
      },
    );
    if (name == null || !context.mounted) return;
    FileEntry? created;
    final directory = ref.read(directoryProvider(path).notifier);
    await context.runWithFeedback(Future(() async => created = await directory.createEmptyFile(name)));
    if (created != null && context.mounted) await context.push(AppRoutes.editor, extra: created);
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    final taken = {for (final entry in ref.read(directoryProvider(path)).value?.entries ?? <FileEntry>[]) entry.name};
    final name = await showTextInputDialog(
      context,
      title: context.localized.noteNewNote,
      label: context.localized.name,
      confirmLabel: context.localized.create,
      initialValue: uniqueName(context.localized.noteDefaultName, noteExtension, taken),
      isValid: (value) => RemotePath.isValidName(value.trim()) && !taken.contains(_withNoteExtension(value.trim())),
    );
    if (name == null || !context.mounted) return;
    FileEntry? created;
    final directory = ref.read(directoryProvider(path).notifier);
    await context.runWithFeedback(
      Future(() async => created = await directory.createEmptyFile(_withNoteExtension(name.trim()))),
    );
    if (created != null && context.mounted) context.go(AppRoutes.noteAt(created!.path));
  }

  static String _withNoteExtension(String name) =>
      RemotePath.extension(name).toLowerCase() == noteExtension ? name : "$name.$noteExtension";

  static String _extension(String name) {
    final dot = name.lastIndexOf(".");
    return dot <= 0 ? "" : name.substring(dot + 1).toLowerCase();
  }
}
