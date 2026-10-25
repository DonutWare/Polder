import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:livemd_flutter/livemd_flutter.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/versions/file_versions_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_history_sheet.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/screens/notes/editor/markdown_view.dart";
import "package:polder/screens/notes/editor/note_editor.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/screens/notes/editor/note_toolbar.dart";
import "package:polder/screens/notes/editor/source_editor.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/services/notes/format_actions.dart";
import "package:polder/services/notes/note_link.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/unique_name.dart";
import "package:polder/widgets/layout/window_centered.dart";
import "package:polder/widgets/shared/centered_progress.dart";
import "package:polder/widgets/shared/error_view.dart";
import "package:polder/widgets/shared/file_link_picker_dialog.dart";
import "package:url_launcher/url_launcher.dart";

const attachmentsFolder = "attachments";

class NotePane extends ConsumerStatefulWidget {
  const NotePane({
    required this.path,
    required this.sourceMode,
    required this.onToggleSourceMode,
    this.leading,
    this.linksShown = false,
    this.onToggleLinks,
    super.key,
  });

  final String path;
  final bool sourceMode;
  final VoidCallback onToggleSourceMode;
  final Widget? leading;
  final bool linksShown;
  final VoidCallback? onToggleLinks;

  @override
  ConsumerState<NotePane> createState() => _NotePaneState();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _NotePaneState extends ConsumerState<NotePane> {
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(onHide: _save, onPause: _save);
  Map<int, FileEntry> _resolved = const {};
  LiveMarkdownController? _controller;
  String _reported = "";
  bool _pickingLink = false;

  NoteDocumentNotifier get _notifier => ref.read(noteDocumentProvider(widget.path).notifier);

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

  LiveMarkdownController _controllerFor(NoteDocument document) {
    final existing = _controller;
    if (existing != null) return existing;
    _reported = document.text;
    return _controller = LiveMarkdownController(text: document.text)..addListener(_onEdited);
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

  Future<void> _openLink(String destination, NoteTargets targets) async {
    final link = targets.parse(destination);
    if (link == null) {
      final uri = Uri.tryParse(destination);
      if (uri != null && uri.hasScheme) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    final api = ref.read(polderApiProvider);
    final byId = link.fileId == null ? null : (await api.filesById([link.fileId!])).firstOrNull;
    final entry = byId ?? (link.path == null ? null : await ref.read(fileAtPathProvider(link.path!).future));
    if (!mounted) return;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.localized.noteLinkMissing)));
      return;
    }
    await openEntry(context, entry);
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
      target.isImage
          ? FormatActions.insertBlock(value, "![$label]($destination)")
          : FormatActions.insert(value, "[$label]($destination)"),
    );
  }

  Future<void> _attachFiles(NoteDocument document) async {
    final picked = await ref.read(filePickerServiceProvider).pickFiles();
    if (picked.isEmpty || !mounted) return;
    final api = ref.read(polderApiProvider);
    final folder = RemotePath.join(RemotePath.parent(document.entry.path), attachmentsFolder);
    await context.runWithFeedback(
      Future(() async {
        final taken = await NotesActions.namesIn(api, folder);
        for (final file in picked) {
          final name = uniqueFileName(file.name, taken);
          taken.add(name);
          final uploaded = await api.putContent(
            RemotePath.join(folder, name),
            file.openRead(),
            length: await file.length() ?? 0,
          );
          if (mounted) _insertLinkTo(uploaded, document.entry.path);
        }
      }),
    );
  }

  Future<void> _showHistory(NoteDocument document) async {
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
    final node = await NotesActions.nodeFor(ref, document.entry);
    if (!mounted) return;
    final renamed = await NotesActions.rename(context, ref, node);
    if (renamed != null && mounted) ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.noteAt(renamed));
  }

  Future<void> _delete(NoteDocument document) async {
    final node = await NotesActions.nodeFor(ref, document.entry);
    if (!mounted) return;
    final deleted = await NotesActions.delete(context, ref, node);
    if (deleted && mounted) ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.notes);
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
            final taken = await NotesActions.namesIn(ref.read(polderApiProvider), folder);
            await _notifier.saveMineAsCopy(uniqueName(base, extension, taken));
          }),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(noteDocumentProvider(widget.path));
    ref.listen(noteDocumentProvider(widget.path), (previous, next) {
      final moved = next.value?.entry.path;
      if (moved != null && moved != widget.path && !(next.value?.dirty ?? true)) {
        ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.noteAt(moved));
      }
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLow.withAlpha(125),
        scrolledUnderElevation: 0,
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
                  Text(
                    RemotePath.parent(document.entry.path),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _SaveStatus(state: document.state, onSave: _notifier.save),
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
              _NoteMenu.history => _showHistory(document),
              _NoteMenu.showInFiles => context.go(
                AppRoutes.filesAt(RemotePath.parent(document.entry.path), select: document.entry.name),
              ),
              _NoteMenu.rename => _rename(document),
              _NoteMenu.delete => _delete(document),
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: _NoteMenu.history, child: Text(localized.versionHistory)),
              PopupMenuItem(value: _NoteMenu.showInFiles, child: Text(localized.noteShowInFiles)),
              PopupMenuItem(value: _NoteMenu.rename, child: Text(localized.rename)),
              PopupMenuItem(value: _NoteMenu.delete, child: Text(localized.delete)),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: readOnly
            ? null
            : NoteToolbar(
                controller: controller,
                contentWidth: _readableWidth,
                onInsertLink: () => _insertLink(document),
                onAttachFiles: () => _attachFiles(document),
              ),
      ),
      body: Column(
        children: [
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
                    final padding = gutters.copyWith(top: 16, bottom: 24);
                    void openLink(String destination) => _openLink(destination, targets);
                    if (readOnly && !sourceMode) {
                      return ReadOnlyNote(text: document.text, targets: targets, padding: padding, onLink: openLink);
                    }
                    return sourceMode
                        ? SourceEditor(controller: controller, readOnly: readOnly, padding: padding)
                        : LiveNoteEditor(
                            controller: controller,
                            padding: padding,
                            onLink: openLink,
                            imageFor: (destination) => noteImage(ref.read(polderApiProvider), targets, destination),
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _readableWidth = 700.0;
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

class _NoteHistoryArrows extends ConsumerWidget {
  const _NoteHistoryArrows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(navigationHistoryProvider);
    final canGoBack = AppRoutes.isNoteLocation(history.previous);
    final canGoForward = AppRoutes.isNoteLocation(history.next);
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

enum _NoteMenu { history, showInFiles, rename, delete }

enum _ConflictChoice { theirs, mine, copy }

class _SaveStatus extends StatelessWidget {
  const _SaveStatus({required this.state, required this.onSave});

  final NoteSaveState state;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final colors = Theme.of(context).colorScheme;
    final (icon, tooltip, color) = switch (state) {
      NoteSaveState.saved => (IconsaxPlusLinear.cloud_add, localized.noteSaved, colors.onSurfaceVariant),
      NoteSaveState.unsaved => (IconsaxPlusLinear.cloud_change, localized.noteUnsaved, colors.primary),
      NoteSaveState.saving => (IconsaxPlusLinear.cloud_change, localized.noteSaving, colors.onSurfaceVariant),
      NoteSaveState.conflict => (IconsaxPlusLinear.cloud_cross, localized.noteConflict, colors.error),
      NoteSaveState.failed => (IconsaxPlusLinear.cloud_cross, localized.noteSaveFailed, colors.error),
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
      onPressed: state == NoteSaveState.unsaved || state == NoteSaveState.failed ? onSave : null,
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
