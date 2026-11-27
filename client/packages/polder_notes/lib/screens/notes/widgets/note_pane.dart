import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_version.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_notes/providers/notes/file_links_provider.dart";
import "package:polder_notes/providers/notes/note_document_provider.dart";
import "package:polder_notes/providers/notes/renamed_note_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/providers/versions/file_versions_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_notes/screens/notes/editor/checklist_editor.dart";
import "package:polder_notes/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder_notes/screens/notes/editor/markdown_view.dart";
import "package:polder_notes/screens/notes/editor/note_editor.dart";
import "package:polder_notes/screens/notes/editor/note_embeds.dart";
import "package:polder_notes/screens/notes/editor/note_toolbar.dart";
import "package:polder_notes/screens/notes/editor/source_editor.dart";
import "package:polder_notes/screens/notes/notes_actions.dart";
import "package:polder_notes/screens/notes/widgets/link_preview_card.dart";
import "package:polder_notes/screens/notes/widgets/note_breadcrumbs.dart";
import "package:polder_notes/screens/notes/widgets/note_subpages.dart";
import "package:polder_notes/services/notes/format_actions.dart";
import "package:polder_notes/services/notes/note_checklist.dart";
import "package:polder_notes/services/notes/note_link.dart";
import "package:polder_notes/services/notes/note_preview.dart";
import "package:polder_notes/services/notes/note_recipe.dart";
import "package:polder_core/services/transfer/file_picker_service.dart";
import "package:polder_ui/util/action_feedback.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/date_format_extension.dart";
import "package:polder_ui/util/external_link.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/util/unique_name.dart";
import "package:polder_ui/widgets/layout/window_centered.dart";
import "package:polder_ui/widgets/shared/app_bar_fade.dart";
import "package:polder_ui/widgets/shared/centered_progress.dart";
import "package:polder_ui/widgets/shared/error_view.dart";
import "package:polder_notes/screens/notes/widgets/file_link_picker_dialog.dart";

const attachmentsFolder = "attachments";

class NotePane extends ConsumerStatefulWidget {
  const NotePane({
    required this.path,
    required this.sourceMode,
    required this.onToggleSourceMode,
    this.leading,
    this.linksShown = false,
    this.onToggleLinks,
    this.onShowFamily,
    super.key,
  });

  final String path;
  final bool sourceMode;
  final VoidCallback onToggleSourceMode;
  final Widget? leading;
  final bool linksShown;
  final VoidCallback? onToggleLinks;
  final VoidCallback? onShowFamily;

  @override
  ConsumerState<NotePane> createState() => _NotePaneState();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _NotePaneState extends ConsumerState<NotePane> {
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(onHide: _save, onPause: _save);
  Map<int, FileEntry> _resolved = const {};
  MarkdownEditingController? _controller;
  String _reported = "";
  bool _pickingLink = false;
  NoteDocument? _carried;

  NoteDocumentNotifier get _notifier => ref.read(noteDocumentProvider(widget.path).notifier);

  @override
  void didUpdateWidget(NotePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _carried = ref.read(noteDocumentProvider(oldWidget.path)).value;
  }

  void _follow(String renamed) {
    ref.read(renamedNoteProvider.notifier).record(widget.path, renamed);
    ref.read(navigationHistoryProvider.notifier).replace(ref.read(notesLocationsProvider).noteAt(renamed));
  }

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller?.dispose();
    super.dispose();
  }

  MarkdownEditingController _controllerFor(NoteDocument document) {
    final existing = _controller;
    if (existing != null) return existing;
    _reported = document.text;
    return _controller = MarkdownEditingController(text: document.text)..addListener(_onEdited);
  }

  void _onEdited() {
    final controller = _controller!;
    if (controller.text == _reported) return;
    final document = ref.read(noteDocumentProvider(widget.path)).value;
    if (document == null) return;
    final trigger = FormatActions.takeLinkTrigger(controller.value, _reported);
    if (trigger != null && !_pickingLink) {
      controller.setValue(trigger, addToHistory: false);
      unawaited(_insertLink(document));
      return;
    }
    _reported = controller.text;
    _notifier.edit(_reported);
  }

  void _followDocument(NoteDocument next) {
    final controller = _controller;
    if (controller == null || next.text == _reported) return;
    _reported = next.text;
    controller.setText(next.text);
  }

  void _save() {
    if (ref.exists(noteDocumentProvider(widget.path))) unawaited(_notifier.save());
  }

  Future<void> _openLink(String destination, NoteTargets targets, String source) async {
    final link = targets.parse(destination);
    if (link == null) {
      await openExternalLink(destination);
      return;
    }
    await context.runWithFeedback(_openLinkTarget(link, targets, source));
  }

  Future<void> _openLinkTarget(NoteLink link, NoteTargets targets, String source) async {
    final entry = await _linkTarget(link, targets);
    if (!mounted) return;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.localized.noteLinkMissing)));
      return;
    }
    await notesHostOf(context).openFile(context, entry, gallery: targets.mediaIn(source, opened: entry));
  }

  Future<FileEntry?> _linkTarget(NoteLink link, NoteTargets targets) async {
    if (targets.knownTarget(link) case final known?) return known;
    if (link.fileId case final id?) {
      if ((await ref.read(filesByIdProvider(fileIdsKey([id])).future))[id] case final byId?) return byId;
    }
    return link.path == null ? null : ref.read(fileAtPathProvider(link.path!).future);
  }

  Future<void> _insertLink(NoteDocument document) async {
    _pickingLink = true;
    final picked = await showFileLinkPicker(
      context,
      startFolder: RemotePath.parent(document.entry.path),
    ).whenComplete(() => _pickingLink = false);
    if (picked == null || !mounted) return;
    _insertLinkTo(picked, document.entry.path);
  }

  void _insertLinkTo(FileEntry target, String notePath) {
    final destination = NoteLink.destinationFor(target, notePath: notePath);
    final fallback = target.displayName;
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    final selected = value.selection.isValid ? value.selection.textInside(value.text) : "";
    final label = escapeLinkLabel(selected.trim().isNotEmpty ? selected : fallback);
    controller.setValue(
      target.isImage || target.isVideo
          ? FormatActions.insertBlock(value, "![$label]($destination)")
          : FormatActions.insert(value, "[$label]($destination)"),
    );
  }

  Future<void> _attachFiles(NoteDocument document) async {
    final picked = await ref.read(filePickerServiceProvider).pickFiles();
    if (!mounted) return;
    await _upload(document, picked);
  }

  Future<void> _upload(NoteDocument document, List<PickedFile> files) async {
    if (files.isEmpty) return;
    final api = ref.read(polderApiProvider);
    final folder = RemotePath.join(RemotePath.parent(document.entry.path), attachmentsFolder);
    await context.runWithFeedback(
      Future(() async {
        final offline = await NotesActions.offlineFor(ref.read(offlineFilesProvider.future), folder);
        final taken = await NotesActions.namesIn(api, folder, offline: offline);
        for (final file in files) {
          final name = uniqueFileName(file.name, taken);
          taken.add(name);
          final path = RemotePath.join(folder, name);
          final attached = offline == null
              ? await api.putContent(path, file.openRead(), length: await file.length() ?? 0)
              : (await offline.queueUpload(path, file.openRead())).entry;
          if (mounted) _insertLinkTo(attached, document.entry.path);
        }
      }),
    );
  }

  void _toggleCheckboxes(MarkdownEditingController controller) {
    final items = NoteChecklist.parse(controller.text);
    final text = items == null ? NoteChecklist.fromText(controller.text) : NoteChecklist.toText(items);
    controller.setValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
      origin: Object(),
    );
  }

  Future<void> _showHistory(NoteDocument document, FileHistoryViewer showFileHistory) async {
    await _notifier.save();
    if (!mounted) return;
    await showFileHistory(
      context,
      document.entry,
      onView: (version) => _showVersion(document.entry, version),
      onRestore: (version) async {
        await ref.read(fileVersionsProvider(document.entry.path).notifier).restore(version);
        await _notifier.checkRemote();
      },
    );
  }

  Future<void> _showVersion(FileEntry entry, FileVersion version) => showDialog<void>(
    context: context,
    builder: (context) => _VersionDialog(entry: entry, version: version),
  );

  Future<void> _rename(NoteDocument document) async {
    await _notifier.save();
    if (!mounted) return;
    final offline = await NotesActions.offlineFor(ref.read(offlineFilesProvider.future), document.entry.path);
    final node = await NotesActions.nodeFor(ref.read(polderApiProvider), document.entry, offline: offline);
    if (!mounted) return;
    final renamed = await NotesActions.rename(context, node);
    if (renamed != null && mounted) _follow(renamed);
  }

  Future<void> _delete(NoteDocument document) async {
    final navigation = ref.read(navigationHistoryProvider.notifier);
    final locations = ref.read(notesLocationsProvider);
    final offline = await NotesActions.offlineFor(ref.read(offlineFilesProvider.future), document.entry.path);
    final node = await NotesActions.nodeFor(ref.read(polderApiProvider), document.entry, offline: offline);
    if (!mounted) return;
    final deleted = await NotesActions.delete(context, node);
    if (deleted) navigation.replace(locations.root);
  }

  Future<void> _resolveConflict(NoteDocument document, _ConflictChoice choice) async {
    switch (choice) {
      case _ConflictChoice.theirs:
        await context.runWithFeedback(_notifier.takeTheirs());
      case _ConflictChoice.mine:
        await context.runWithFeedback(_notifier.keepMine());
      case _ConflictChoice.copy:
        final folder = RemotePath.parent(document.entry.path);
        final base = "${RemotePath.withoutExtension(document.entry.name)} (${context.localized.copySuffix})";
        final extension = RemotePath.extension(document.entry.name);
        await context.runWithFeedback(
          Future(() async {
            final offline = await NotesActions.offlineFor(ref.read(offlineFilesProvider.future), folder);
            final taken = await NotesActions.namesIn(ref.read(polderApiProvider), folder, offline: offline);
            await _notifier.saveMineAsCopy(uniqueName(base, extension, taken));
          }),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(noteDocumentProvider(widget.path));
    final document = switch (_carried) {
      final carried? when !loaded.hasValue => AsyncData(carried),
      _ => loaded,
    };
    ref.listen(noteDocumentProvider(widget.path), (previous, next) {
      final moved = next.value?.entry.path;
      if (moved != null && moved != widget.path && !(next.value?.dirty ?? true)) _follow(moved);
      if (next.hasValue) _carried = null;
      if (next.value case final value?) _followDocument(value);
    });
    return AnimatedSwitcher(
      duration: _fadeDuration,
      child: switch (document) {
        AsyncValue(hasValue: true, :final value?) => KeyedSubtree(
          key: const ValueKey(#note),
          child: _page(context, value),
        ),
        AsyncError(:final error) => ErrorView(
          key: const ValueKey(#error),
          error: error,
          onRetry: () => ref.invalidate(noteDocumentProvider(widget.path)),
        ),
        _ => const _OpeningNote(key: ValueKey(#opening)),
      },
    );
  }

  Widget _page(BuildContext context, NoteDocument document) {
    final localized = context.localized;
    final sourceMode = widget.sourceMode;
    final name = RemotePath.withoutExtension(document.entry.name);
    final targets = _targets(document);
    final readOnly = !document.editable || document.state == NoteSaveState.conflict;
    final controller = _controllerFor(document);
    final checklist = !sourceMode && NoteChecklist.isChecklist(controller.text);
    final recipe = !checklist && NoteRecipe.isRecipe(controller.text);
    final colors = Theme.of(context).colorScheme;
    final banners = _banners(document, localized);
    final host = ref.watch(notesHostProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: const AppBarFade(),
        leading: widget.leading,
        titleSpacing: widget.leading == null ? null : 0,
        title: Row(
          children: [
            const _NoteHistoryArrows(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: localized.rename,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: readOnly ? null : () => _rename(document),
                      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  NoteBreadcrumbs(notePath: document.entry.path),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _SaveStatus(
            state: document.state,
            error: document.saveError,
            onSave: _notifier.save,
            onSync: _notifier.retrySync,
          ),
          if (recipe)
            IconButton(
              tooltip: localized.recipeStartCooking,
              icon: const Icon(IconsaxPlusLinear.cake),
              onPressed: () => context.push(notesLocationsOf(context).cookAt(document.entry.path)),
            ),
          if (widget.onShowFamily case final onShowFamily?)
            IconButton(
              tooltip: localized.notesShowFamilyTree,
              icon: const Icon(IconsaxPlusLinear.hierarchy),
              onPressed: onShowFamily,
            ),
          IconButton(
            tooltip: sourceMode ? localized.noteLivePreview : localized.noteSourceMode,
            isSelected: sourceMode,
            icon: const Icon(IconsaxPlusLinear.code_1),
            selectedIcon: Icon(IconsaxPlusBold.code_1, color: colors.primary),
            onPressed: widget.onToggleSourceMode,
          ),
          if (widget.onToggleLinks != null)
            IconButton(
              tooltip: localized.noteLinks,
              isSelected: widget.linksShown,
              icon: const Icon(IconsaxPlusLinear.link_21),
              selectedIcon: Icon(IconsaxPlusBold.link_21, color: colors.primary),
              onPressed: widget.onToggleLinks,
            ),
          PopupMenuButton<_NoteMenu>(
            onSelected: (choice) => switch (choice) {
              _NoteMenu.history => _showHistory(document, host.showFileHistory!),
              _NoteMenu.showInFiles => host.showInFiles!(context, document.entry),
              _NoteMenu.rename => _rename(document),
              _NoteMenu.delete => _delete(document),
              _NoteMenu.checkboxes => _toggleCheckboxes(controller),
            },
            itemBuilder: (context) => [
              if (!readOnly)
                PopupMenuItem(
                  value: _NoteMenu.checkboxes,
                  child: Text(
                    NoteChecklist.isChecklist(controller.text)
                        ? localized.noteHideCheckboxes
                        : localized.noteShowCheckboxes,
                  ),
                ),
              if (host.showFileHistory != null)
                PopupMenuItem(value: _NoteMenu.history, child: Text(localized.versionHistory)),
              if (host.showInFiles != null)
                PopupMenuItem(value: _NoteMenu.showInFiles, child: Text(localized.noteShowInFiles)),
              PopupMenuItem(value: _NoteMenu.rename, child: Text(localized.rename)),
              PopupMenuItem(value: _NoteMenu.delete, child: Text(localized.delete)),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: readOnly || checklist
            ? null
            : NoteToolbar(
                controller: controller,
                contentWidth: _readableWidth,
                onInsertLink: () => _insertLink(document),
                onAttachFiles: () => _attachFiles(document),
              ),
      ),
      body: _AboveNavigation(
        child: Column(
          children: [
            if (banners.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                child: Column(children: banners),
              ),
            Expanded(
              child: Shortcuts(
                shortcuts: {
                  ...noteHistoryShortcuts,
                  const SingleActivator(LogicalKeyboardKey.keyS, control: true): const _SaveIntent(),
                  const SingleActivator(LogicalKeyboardKey.keyS, meta: true): const _SaveIntent(),
                },
                child: Actions(
                  actions: {
                    UndoNoteIntent: CallbackAction<UndoNoteIntent>(onInvoke: (_) => controller.undo()),
                    RedoNoteIntent: CallbackAction<RedoNoteIntent>(onInvoke: (_) => controller.redo()),
                    _SaveIntent: CallbackAction<_SaveIntent>(onInvoke: (_) => _notifier.save()),
                  },
                  child: WindowCentered(
                    contentWidth: _readableWidth,
                    builder: (context, gutters) {
                      final barInset = banners.isEmpty ? MediaQuery.paddingOf(context).top : 0.0;
                      final padding = gutters.copyWith(top: barInset + 16, bottom: 24);
                      void openLink(String destination) =>
                          _openLink(destination, targets, _controller?.value.text ?? document.text);
                      if (readOnly && !sourceMode) {
                        return ReadOnlyNote(text: document.text, targets: targets, padding: padding, onLink: openLink);
                      }
                      if (sourceMode) return SourceEditor(controller: controller, readOnly: readOnly, padding: padding);
                      if (checklist) return ChecklistEditor(controller: controller, padding: padding);
                      return LiveNoteEditor(
                        controller: controller,
                        targets: targets,
                        padding: padding,
                        onLink: openLink,
                        onDropFiles: (files) => _upload(document, files.map(XFilePickedFile.new).toList()),
                        imageFor: (destination) => noteImage(
                          ref.read(polderApiProvider),
                          targets,
                          destination,
                          offline: ref.read(offlineFilesProvider).value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _NoteLinkPreviews(path: widget.path, contentWidth: _readableWidth),
            NoteSubpages(path: widget.path, contentWidth: _readableWidth),
          ],
        ),
      ),
    );
  }

  List<Widget> _banners(NoteDocument document, AppLocalizations localized) => [
    if (!document.editable) _Banner(icon: Icons.lock_outline, message: localized.noteNotText),
    if (document.draft case final draft?)
      _Banner(
        icon: Icons.restore,
        message: draft.baseHash == document.entry.hash
            ? localized.noteDraftFound(draft.updatedAt.formatted(context))
            : localized.noteDraftFoundChanged(draft.updatedAt.formatted(context)),
        actions: [
          TextButton(onPressed: _notifier.discardDraft, child: Text(localized.noteDiscardDraft)),
          FilledButton.tonal(onPressed: _notifier.recoverDraft, child: Text(localized.noteRecoverDraft)),
        ],
      ),
    if (document.state == NoteSaveState.conflict)
      _Banner(
        icon: Icons.sync_problem,
        message: localized.noteConflict,
        actions: [
          TextButton(
            onPressed: () => _resolveConflict(document, _ConflictChoice.theirs),
            child: Text(localized.noteConflictTheirs),
          ),
          TextButton(
            onPressed: () => _resolveConflict(document, _ConflictChoice.copy),
            child: Text(localized.noteConflictCopy),
          ),
          FilledButton.tonal(
            onPressed: () => _resolveConflict(document, _ConflictChoice.mine),
            child: Text(localized.noteConflictMine),
          ),
        ],
      ),
  ];

  static const _readableWidth = 1200.0;
  static const _fadeDuration = Duration(milliseconds: 180);

  NoteTargets _targets(NoteDocument document) {
    final ids = {
      for (final link in findSourceLinks(document.text))
        ?NoteLink.parse(link.destination, notePath: document.entry.path)?.fileId,
    };
    if (ids.isNotEmpty) {
      final resolved = ref.watch(filesByIdProvider(fileIdsKey(ids))).value;
      if (resolved != null) _resolved = {..._resolved, ...resolved};
    }
    return NoteTargets(notePath: document.entry.path, byId: _resolved);
  }
}

class _AboveNavigation extends StatelessWidget {
  const _AboveNavigation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final inset = keyboardOpen ? 0.0 : MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: MediaQuery.removePadding(context: context, removeBottom: true, child: child),
    );
  }
}

class _NoteHistoryArrows extends ConsumerWidget {
  const _NoteHistoryArrows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(navigationHistoryProvider);
    final locations = ref.watch(notesLocationsProvider);
    final canGoBack = locations.isNoteLocation(history.previous);
    final canGoForward = locations.isNoteLocation(history.next);
    if (!canGoBack && !canGoForward) return const SizedBox.shrink();
    final localized = context.localized;
    final notifier = ref.read(navigationHistoryProvider.notifier);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: localized.noteBack,
            icon: const Icon(IconsaxPlusLinear.arrow_left_1),
            onPressed: canGoBack ? () => unawaited(notifier.back()) : null,
          ),
          IconButton(
            tooltip: localized.noteForward,
            icon: const Icon(IconsaxPlusLinear.arrow_right_3),
            onPressed: canGoForward ? notifier.forward : null,
          ),
        ],
      ),
    );
  }
}

class _OpeningNote extends StatefulWidget {
  const _OpeningNote({super.key});

  static const progressDelay = Duration(milliseconds: 400);

  @override
  State<_OpeningNote> createState() => _OpeningNoteState();
}

class _OpeningNoteState extends State<_OpeningNote> {
  late final Timer _timer = Timer(_OpeningNote.progressDelay, () => setState(() => _slow = true));
  var _slow = false;

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: _slow ? const CenteredProgress() : const SizedBox.expand(),
  );
}

enum _NoteMenu { checkboxes, history, showInFiles, rename, delete }

enum _ConflictChoice { theirs, mine, copy }

class _SaveStatus extends StatelessWidget {
  const _SaveStatus({required this.state, required this.error, required this.onSave, required this.onSync});

  final NoteSaveState state;
  final Object? error;
  final Future<void> Function() onSave;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final colors = Theme.of(context).colorScheme;
    final (icon, tooltip, color) = switch (state) {
      NoteSaveState.saved => (IconsaxPlusLinear.cloud_add, localized.noteSynced, colors.onSurfaceVariant),
      NoteSaveState.unsaved => (IconsaxPlusLinear.cloud_change, localized.noteUnsaved, colors.primary),
      NoteSaveState.saving => (IconsaxPlusLinear.cloud_change, localized.noteSaving, colors.onSurfaceVariant),
      NoteSaveState.pending => (IconsaxPlusLinear.mobile, localized.noteSavedOnDevice, colors.primary),
      NoteSaveState.conflict => (IconsaxPlusLinear.cloud_cross, localized.noteConflict, colors.error),
      NoteSaveState.failed => (
        IconsaxPlusLinear.cloud_remove,
        "${localized.noteNotSynced}\n${context.syncExplanation(error)}",
        colors.error,
      ),
    };
    if (state == NoteSaveState.saving) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: color),
      onPressed: switch (state) {
        NoteSaveState.unsaved => onSave,
        NoteSaveState.pending || NoteSaveState.failed => onSync,
        _ => null,
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.message, this.actions = const []});

  final IconData icon;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: colors.onSecondaryContainer),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(message, style: TextStyle(color: colors.onSecondaryContainer)),
                ),
              ],
            ),
            if (actions.isNotEmpty) Row(mainAxisSize: MainAxisSize.min, children: actions),
          ],
        ),
      ),
    );
  }
}

class _VersionDialog extends ConsumerStatefulWidget {
  const _VersionDialog({required this.entry, required this.version});

  final FileEntry entry;
  final FileVersion version;

  @override
  ConsumerState<_VersionDialog> createState() => _VersionDialogState();
}

class _VersionDialogState extends ConsumerState<_VersionDialog> {
  late final Future<Uint8List> _content = ref.read(polderApiProvider).downloadVersion(widget.version.id);

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.version.modifiedAt.formatted(context)),
    content: SizedBox(
      width: 720,
      child: FutureBuilder(
        future: _content,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) {
            return snapshot.hasError
                ? Text(context.localized.describeError(snapshot.error))
                : const Center(child: CircularProgressIndicator());
          }
          return ReadOnlyNote(
            text: utf8.decode(bytes, allowMalformed: true),
            targets: NoteTargets(notePath: widget.entry.path, byId: const {}),
            onLink: (_) {},
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
      ),
    ],
  );
}

class _NoteLinkPreviews extends ConsumerStatefulWidget {
  const _NoteLinkPreviews({required this.path, required this.contentWidth});

  final String path;
  final double contentWidth;

  @override
  ConsumerState<_NoteLinkPreviews> createState() => _NoteLinkPreviewsState();
}

class _NoteLinkPreviewsState extends ConsumerState<_NoteLinkPreviews> {
  static const _settleDelay = Duration(milliseconds: 600);

  Timer? _settle;
  var _links = const <String>[];

  @override
  void initState() {
    super.initState();
    _links = _linksIn(ref.read(noteDocumentProvider(widget.path)).value?.text);
  }

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  static List<String> _linksIn(String? text) => text == null ? const [] : NotePreview.webLinksIn(text);

  void _textChanged(String? text) {
    _settle?.cancel();
    _settle = Timer(_settleDelay, () {
      final links = _linksIn(text);
      if (mounted && !listEquals(links, _links)) setState(() => _links = links);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      noteDocumentProvider(widget.path).select((document) => document.value?.text),
      (_, text) => _textChanged(text),
    );
    if (_links.isEmpty || MediaQuery.viewInsetsOf(context).bottom > 0) return const SizedBox.shrink();
    return WindowCentered(
      contentWidth: widget.contentWidth,
      builder: (context, gutters) => LinkPreviewStrip(urls: _links, gutters: gutters),
    );
  }
}
