import "package:flutter/material.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";

import "package:polder/screens/notes/editor/markdown_syntax_controller.dart";
import "package:polder/screens/notes/editor/note_editor.dart";

class SourceEditor extends StatefulWidget {
  const SourceEditor({required this.controller, this.readOnly = false, this.padding = EdgeInsets.zero, super.key});

  final MarkdownEditingController controller;
  final bool readOnly;
  final EdgeInsets padding;

  @override
  State<SourceEditor> createState() => _SourceEditorState();
}

class _SourceEditorState extends State<SourceEditor> {
  static const _typingGroup = Duration(milliseconds: 800);

  late final MarkdownSyntaxController _controller = MarkdownSyntaxController()
    ..value = widget.controller.value
    ..addListener(_toDocument);
  final _typingOrigin = Object();
  DateTime? _lastTyped;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_fromDocument);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_fromDocument);
    _controller.dispose();
    super.dispose();
  }

  void _toDocument() {
    if (_syncing) return;
    final textChanged = _controller.text != widget.controller.text;
    final now = DateTime.now();
    final merge = textChanged && _lastTyped != null && now.difference(_lastTyped!) < _typingGroup;
    if (textChanged) _lastTyped = now;
    _syncing = true;
    widget.controller.setValue(_controller.value, origin: textChanged ? _typingOrigin : null, mergeWithPrevious: merge);
    _syncing = false;
  }

  void _fromDocument() {
    if (_syncing || _controller.value == widget.controller.value) return;
    _syncing = true;
    _controller.value = widget.controller.value;
    _syncing = false;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: widget.padding,
    child: TextField(
      controller: _controller,
      readOnly: widget.readOnly,
      autofocus: true,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: noteFieldDecoration,
    ),
  );
}
