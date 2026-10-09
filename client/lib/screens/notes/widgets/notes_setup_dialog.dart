import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";

Future<String?> showNotesSetupDialog(BuildContext context, {String? suggestion}) => showDialog<String>(
  context: context,
  builder: (_) => NotesSetupDialog(suggestion: suggestion),
);

class NotesSetupDialog extends ConsumerStatefulWidget {
  const NotesSetupDialog({this.suggestion, super.key});

  final String? suggestion;

  @override
  ConsumerState<NotesSetupDialog> createState() => _NotesSetupDialogState();
}

enum _Step { chooseName, existing }

class _NotesSetupDialogState extends ConsumerState<NotesSetupDialog> {
  late final _controller = TextEditingController();
  var _step = _Step.chooseName;
  var _busy = false;
  String? _error;
  String _existingFolderPath = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.text.isEmpty) {
      _controller.text =
          RemotePath.relativeTo(widget.suggestion ?? "", RemotePath.root) ?? context.localized.notesDefaultFolder;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String? _pathFor(String input) {
    final segments = RemotePath.segments(input.trim());
    if (segments.isEmpty || !segments.every(RemotePath.isValidName)) return null;
    return "/${segments.join("/")}";
  }

  Future<void> _submit() async {
    final path = _pathFor(_controller.text);
    if (path == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(polderApiProvider);
    try {
      final existing = await api.stat(path);
      if (!mounted) return;
      if (!existing.isDir) {
        setState(() => _error = context.localized.notesFolderIsFile);
      } else {
        setState(() {
          _existingFolderPath = path;
          _step = _Step.existing;
        });
      }
    } on NotFoundException {
      try {
        await _createFolder(path);
        await _choose(path);
      } on ApiException catch (error) {
        if (mounted) setState(() => _error = context.localized.describeError(error));
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = context.localized.describeError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createFolder(String path) async {
    final api = ref.read(polderApiProvider);
    for (final ancestor in RemotePath.ancestry(path).skip(1)) {
      if (!await _exists(ancestor)) await api.mkdir(ancestor);
    }
  }

  Future<bool> _exists(String path) async {
    try {
      await ref.read(polderApiProvider).stat(path);
      return true;
    } on NotFoundException {
      return false;
    }
  }

  Future<void> _choose(String path) async {
    await ref.read(notesFolderProvider.notifier).choose(path);
    if (mounted) Navigator.pop(context, path);
  }

  Future<void> _browse() async {
    final picked = await showRemoteFolderPicker(context);
    if (picked == null || picked == RemotePath.root || !mounted) return;
    _controller.text = RemotePath.relativeTo(picked, RemotePath.root) ?? "";
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    if (_step == _Step.existing) {
      return AlertDialog(
        icon: const Icon(IconsaxPlusLinear.folder_open),
        title: Text(localized.notesFolderExistsTitle),
        content: Text(localized.notesFolderExistsMessage(_existingFolderPath)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _step = _Step.chooseName),
            child: Text(localized.notesChooseAnotherName),
          ),
          FilledButton(
            onPressed: _busy ? null : () => _runShowingErrors(() => _choose(_existingFolderPath)),
            child: Text(localized.notesUseExistingFolder),
          ),
        ],
      );
    }
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.note_2),
      title: Text(localized.notesSetupTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(localized.notesSetupMessage),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: localized.notesFolder,
              prefixText: "/",
              errorText: _error,
              suffixIcon: IconButton(
                tooltip: localized.chooseServerFolder,
                icon: const Icon(IconsaxPlusLinear.folder_open),
                onPressed: _busy ? null : _browse,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => FilledButton(
            onPressed: _busy || _pathFor(_controller.text) == null ? null : _submit,
            child: Text(localized.notesSetUp),
          ),
        ),
      ],
    );
  }

  Future<void> _runShowingErrors(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = context.localized.describeError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
