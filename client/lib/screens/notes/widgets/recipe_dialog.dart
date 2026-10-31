import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/loading_button.dart";

typedef CreateCustomRecipe = Future<FileEntry> Function(String name);

Future<FileEntry?> showRecipeDialog(
  BuildContext context, {
  required String folder,
  required CreateCustomRecipe createCustom,
}) => showDialog<FileEntry>(
  context: context,
  builder: (_) => RecipeDialog(folder: folder, createCustom: createCustom),
);

enum _RecipeSource { link, paste, custom }

class RecipeDialog extends ConsumerStatefulWidget {
  const RecipeDialog({required this.folder, required this.createCustom, super.key});

  final String folder;
  final CreateCustomRecipe createCustom;

  @override
  ConsumerState<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends ConsumerState<RecipeDialog> {
  final _link = TextEditingController();
  final _name = TextEditingController();
  _RecipeSource _source = _RecipeSource.link;
  String _pasted = "";
  bool _working = false;
  String? _error;

  static bool _isWebLink(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == "http" || uri.scheme == "https") && uri.host.isNotEmpty;
  }

  bool get _canSubmit => switch (_source) {
    _RecipeSource.link => _isWebLink(_link.text),
    _RecipeSource.paste => _pasted.trim().isNotEmpty && (_link.text.trim().isEmpty || _isWebLink(_link.text)),
    _RecipeSource.custom => RemotePath.isValidName(_name.text.trim()),
  };

  @override
  void initState() {
    super.initState();
    _pasteLinkFromClipboard();
  }

  Future<String?> _clipboardText() async => (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim();

  Future<void> _pasteLinkFromClipboard() async {
    final copied = await _clipboardText();
    if (!mounted || copied == null || !_isWebLink(copied) || _link.text.isNotEmpty) return;
    setState(() {
      _link.value = TextEditingValue(
        text: copied,
        selection: TextSelection(baseOffset: 0, extentOffset: copied.length),
      );
    });
  }

  Future<void> _pasteRecipe() async {
    final copied = await _clipboardText();
    if (!mounted) return;
    setState(() {
      _pasted = copied ?? "";
      _error = copied == null || copied.isEmpty ? context.localized.recipeImportClipboardEmpty : null;
    });
  }

  @override
  void dispose() {
    _link.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<FileEntry> _create() {
    if (_source == _RecipeSource.custom) return widget.createCustom(_name.text.trim());
    final link = _link.text.trim();
    return ref
        .read(polderApiProvider)
        .importRecipe(
          url: link.isEmpty ? null : link,
          content: _source == _RecipeSource.paste ? _pasted : null,
          folder: widget.folder,
        );
  }

  Future<void> _submit() async {
    if (_working || !_canSubmit) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final created = await _create();
      if (mounted) Navigator.pop(context, created);
    } on ForbiddenException {
      if (mounted && _source == _RecipeSource.link) _offerPaste();
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = context.localized.describeError(error);
        });
      }
    }
  }

  void _offerPaste() => setState(() {
    _working = false;
    _source = _RecipeSource.paste;
    _error = context.localized.recipeImportRefused;
  });

  void _switchTo(_RecipeSource source) => setState(() {
    _source = source;
    _error = null;
  });

  String _message(BuildContext context) => switch (_source) {
    _RecipeSource.link => context.localized.recipeImportMessage,
    _RecipeSource.paste => context.localized.recipeImportPasteMessage,
    _RecipeSource.custom => context.localized.recipeFromScratchMessage,
  };

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.recipeAdd),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_RecipeSource>(
              segments: [
                ButtonSegment(
                  value: _RecipeSource.link,
                  icon: const Icon(IconsaxPlusLinear.link_21),
                  label: Text(localized.recipeImportFromLink),
                ),
                ButtonSegment(
                  value: _RecipeSource.paste,
                  icon: const Icon(IconsaxPlusLinear.clipboard_text),
                  label: Text(localized.recipeImportFromPaste),
                ),
                ButtonSegment(
                  value: _RecipeSource.custom,
                  icon: const Icon(IconsaxPlusLinear.edit_2),
                  label: Text(localized.recipeFromScratch),
                ),
              ],
              selected: {_source},
              onSelectionChanged: _working ? null : (selection) => _switchTo(selection.single),
            ),
            const SizedBox(height: 16),
            Text(_message(context)),
            const SizedBox(height: 16),
            ...switch (_source) {
              _RecipeSource.link => [_linkField(localized.recipeImportLink)],
              _RecipeSource.paste => [
                _PastedRecipe(text: _pasted, onPaste: _working ? null : _pasteRecipe),
                const SizedBox(height: 16),
                _linkField(localized.recipeImportLinkOptional),
              ],
              _RecipeSource.custom => [
                TextField(
                  key: const ValueKey(#name),
                  controller: _name,
                  autofocus: true,
                  enabled: !_working,
                  decoration: InputDecoration(labelText: localized.name),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            },
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _working ? null : () => Navigator.pop(context), child: Text(localized.cancel)),
        LoadingButton(
          label: _source == _RecipeSource.custom ? localized.create : localized.recipeImportAction,
          loading: _working,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
    );
  }

  Widget _linkField(String label) => TextField(
    key: const ValueKey(#link),
    controller: _link,
    autofocus: _source == _RecipeSource.link,
    enabled: !_working,
    keyboardType: TextInputType.url,
    decoration: InputDecoration(labelText: label),
    onChanged: (_) => setState(() {}),
    onSubmitted: (_) => _submit(),
  );
}

class _PastedRecipe extends StatelessWidget {
  const _PastedRecipe({required this.text, required this.onPaste});

  static const _previewLength = 400;

  final String text;
  final VoidCallback? onPaste;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.tonalIcon(
          onPressed: onPaste,
          icon: const Icon(IconsaxPlusLinear.clipboard_import),
          label: Text(context.localized.recipeImportPasteButton),
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.localized.recipeImportPastedLength(text.length), style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  text.substring(0, text.length.clamp(0, _previewLength)),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
