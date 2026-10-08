import "package:flutter/material.dart";

import "package:polder/util/localization_helper.dart";

Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initialValue = "",
  bool Function(String value)? isValid,
  int maxLines = 1,
}) => showDialog<String>(
  context: context,
  builder: (_) => TextInputDialog(
    title: title,
    label: label,
    confirmLabel: confirmLabel,
    initialValue: initialValue,
    isValid: isValid ?? (value) => value.trim().isNotEmpty,
    maxLines: maxLines,
  ),
);

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initialValue,
    required this.isValid,
    this.maxLines = 1,
    super.key,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String initialValue;
  final bool Function(String value) isValid;
  final int maxLines;

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue)
    ..selection = TextSelection(baseOffset: 0, extentOffset: _selectionEnd(widget.initialValue));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: 1,
      maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.localized.cancel)),
      ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => FilledButton(
          onPressed: widget.isValid(_controller.text) ? _submit : null,
          child: Text(widget.confirmLabel),
        ),
      ),
    ],
  );

  void _submit() {
    if (widget.isValid(_controller.text)) Navigator.pop(context, _controller.text.trim());
  }

  static int _selectionEnd(String name) {
    final extensionStart = name.lastIndexOf(".");
    return extensionStart > 0 ? extensionStart : name.length;
  }
}
