import "dart:async";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_commands.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor_style.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_projection.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    required this.controller,
    required this.style,
    required this.imageFor,
    this.blockBuilder,
    this.onLinkTap,
    this.onImageTap,
    this.onDropFiles,
    this.padding = EdgeInsets.zero,
    this.decoration = const InputDecoration.collapsed(hintText: null),
    this.autofocus = false,
    this.enableSuggestions = true,
    super.key,
  });

  final MarkdownEditingController controller;
  final MarkdownEditorStyle style;
  final ImageProvider Function(String destination) imageFor;
  final MarkdownBlockBuilder? blockBuilder;
  final void Function(String destination)? onLinkTap;
  final void Function(String destination)? onImageTap;
  final void Function(List<XFile> files)? onDropFiles;
  final EdgeInsets padding;
  final InputDecoration decoration;
  final bool autofocus;
  final bool enableSuggestions;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  final _fieldKey = GlobalKey();
  late final FocusNode _focus = FocusNode(onKeyEvent: _handleKey)..addListener(_refresh);
  final _scroll = ScrollController();
  bool _plainNewline = false;
  bool _dragging = false;
  _PointerDown? _down;
  double? _caretHeight;

  MarkdownEditingController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCaretHeight);
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller
        ..removeListener(_updateCaretHeight)
        ..presentation = null;
      widget.controller.addListener(_updateCaretHeight);
    }
    _caretHeight = null;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateCaretHeight)
      ..presentation = null;
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _updateCaretHeight() {
    final next = _caretHeightAt(_controller.selection.extentOffset);
    if (next != _caretHeight) setState(() => _caretHeight = next);
  }

  double _caretHeightAt(int offset) {
    final source = _controller.source;
    final line = offset < 0 ? null : source.lineAt(offset.clamp(0, source.text.length));
    final body = widget.style.body;
    final style = line != null && line.block == null && line.kind == MarkdownLineKind.heading
        ? widget.style.heading(body, line.level)
        : body;
    final painter = TextPainter(
      text: TextSpan(text: " ", style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final height = painter.preferredLineHeight;
    painter.dispose();
    return height;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final command = keyboard.isMetaPressed || keyboard.isControlPressed;
    final key = event.logicalKey;
    if (command && key == LogicalKeyboardKey.keyZ) {
      keyboard.isShiftPressed ? _controller.redo() : _controller.undo();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _plainNewline = keyboard.isShiftPressed;
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.tab && !command) {
      final value = _controller.value;
      final next =
          indentMarkdownLines(value, outdent: keyboard.isShiftPressed) ??
          (_inCodeBlock(value.selection) ? _insertSpaces(value) : null);
      if (next == null) return KeyEventResult.ignored;
      _controller.setValue(next, origin: Object());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _inCodeBlock(TextSelection selection) {
    if (!selection.isValid) return false;
    return _controller.source.lineAt(selection.start).block?.kind == MarkdownBlockKind.code;
  }

  TextEditingValue _insertSpaces(TextEditingValue value) {
    final selection = value.selection;
    return TextEditingValue(
      text: value.text.replaceRange(selection.start, selection.end, "  "),
      selection: TextSelection.collapsed(offset: selection.start + 2),
    );
  }

  bool _takePlainNewline() {
    final plain = _plainNewline;
    _plainNewline = false;
    return plain;
  }

  void _toggleTask(MarkdownLine line) {
    final state = line.checkbox! + 1;
    final value = _controller.value;
    _controller.setValue(
      value.copyWith(
        text: value.text.replaceRange(state, state + 1, value.text[state] == " " ? "x" : " "),
        composing: TextRange.empty,
      ),
      origin: Object(),
    );
  }

  void _revealBlock(MarkdownBlock block) {
    final text = _controller.text;
    final firstBreak = text.indexOf("\n", block.start);
    final offset = firstBreak < 0 || firstBreak >= block.end ? block.end : firstBreak + 1;
    _controller.setValue(
      _controller.value.copyWith(selection: TextSelection.collapsed(offset: offset)),
      addToHistory: false,
    );
    _focus.requestFocus();
  }

  RenderEditable? _editable() {
    RenderEditable? found;
    void visit(RenderObject child) {
      if (found != null) return;
      if (child is RenderEditable) {
        found = child;
        return;
      }
      child.visitChildren(visit);
    }

    _fieldKey.currentContext?.findRenderObject()?.visitChildren(visit);
    return found;
  }

  int? _offsetAt(Offset global) => _editable()?.getPositionForPoint(global).offset;

  void _pointerDown(PointerDownEvent event) {
    _down = event.buttons == kPrimaryButton || event.kind != PointerDeviceKind.mouse
        ? _PointerDown(event.position, _controller.selection, _focus.hasFocus)
        : null;
  }

  void _pointerUp(PointerUpEvent event) {
    final down = _down;
    _down = null;
    if (down == null || widget.onLinkTap == null || (event.position - down.position).distance > kTouchSlop) return;
    final link = _linkAt(event.position, down);
    if (link == null) return;
    widget.onLinkTap!(link);
    scheduleMicrotask(() {
      if (!mounted) return;
      _controller.setValue(_controller.value.copyWith(selection: down.selection), addToHistory: false);
      if (!down.focused) _focus.unfocus();
    });
  }

  String? _linkAt(Offset global, _PointerDown down) {
    final editable = _editable();
    if (editable == null) return null;
    final offset = editable.getPositionForPoint(global).offset;
    final source = _controller.source;
    final node = source.inlineAt(
      offset,
      (node) => node.kind == MarkdownInlineKind.link || node.kind == MarkdownInlineKind.url,
    );
    if (node == null || rendersAsEmbed(source.text, node, source.lineAt(node.start))) return null;
    final selection = down.selection;
    final wasActive = down.focused && selection.isValid && selection.start <= node.end && selection.end >= node.start;
    if (wasActive) return null;
    final local = editable.globalToLocal(global);
    final boxes = editable.getBoxesForSelection(TextSelection(baseOffset: node.start, extentOffset: node.end));
    if (!boxes.any((box) => box.toRect().inflate(2).contains(local))) return null;
    return markdownDestination(source.text, node);
  }

  void _dropped(DropDoneDetails details) {
    setState(() => _dragging = false);
    final files = details.files.where((file) => file is! DropItemDirectory).toList();
    if (files.isEmpty) return;
    final offset = _offsetAt(details.globalPosition);
    if (offset != null) {
      _controller.setValue(
        _controller.value.copyWith(selection: TextSelection.collapsed(offset: offset)),
        addToHistory: false,
      );
    }
    _focus.requestFocus();
    widget.onDropFiles!(files);
  }

  @override
  Widget build(BuildContext context) {
    final editor = Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _controller.presentation = MarkdownPresentation(
            style: widget.style,
            width: constraints.maxWidth,
            focused: _focus.hasFocus,
            imageFor: widget.imageFor,
            blockBuilder: widget.blockBuilder,
            onImageTap: (destination) => widget.onImageTap?.call(destination),
            onToggleTask: _toggleTask,
            onRevealBlock: _revealBlock,
          );
          return Listener(
            onPointerDown: _pointerDown,
            onPointerUp: _pointerUp,
            onPointerCancel: (_) => _down = null,
            child: TextField(
              key: _fieldKey,
              controller: _controller,
              focusNode: _focus,
              scrollController: _scroll,
              autofocus: widget.autofocus,
              expands: true,
              minLines: null,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textAlignVertical: TextAlignVertical.top,
              style: widget.style.body,
              strutStyle: StrutStyle.disabled,
              cursorHeight: _caretHeight ??= _caretHeightAt(_controller.selection.extentOffset),
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              autocorrect: false,
              enableSuggestions: widget.enableSuggestions,
              decoration: widget.decoration,
              inputFormatters: [_MarkdownInputFormatter(_takePlainNewline)],
            ),
          );
        },
      ),
    );
    if (widget.onDropFiles == null) return editor;
    final colors = Theme.of(context).colorScheme;
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: _dropped,
      child: Stack(
        fit: StackFit.expand,
        children: [
          editor,
          if (_dragging)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  border: Border.all(color: colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PointerDown {
  const _PointerDown(this.position, this.selection, this.focused);

  final Offset position;
  final TextSelection selection;
  final bool focused;
}

class _MarkdownInputFormatter extends TextInputFormatter {
  _MarkdownInputFormatter(this.takePlainNewline);

  final bool Function() takePlainNewline;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final composing = newValue.composing;
    if (composing.isValid && !composing.isCollapsed) return newValue;
    if (_insertedNewline(oldValue, newValue)) {
      if (takePlainNewline()) return newValue;
      return continueMarkdownLine(oldValue) ?? newValue;
    }
    if (_deletedBackward(oldValue, newValue)) return removeMarkdownMarker(oldValue) ?? newValue;
    return newValue;
  }

  static bool _insertedNewline(TextEditingValue oldValue, TextEditingValue newValue) {
    final selection = oldValue.selection;
    if (!selection.isValid || !newValue.selection.isCollapsed) return false;
    return newValue.selection.baseOffset == selection.start + 1 &&
        newValue.text == oldValue.text.replaceRange(selection.start, selection.end, "\n");
  }

  static bool _deletedBackward(TextEditingValue oldValue, TextEditingValue newValue) {
    final selection = oldValue.selection;
    if (!selection.isValid || !selection.isCollapsed || selection.baseOffset == 0) return false;
    final caret = selection.baseOffset;
    return newValue.selection.isCollapsed &&
        newValue.selection.baseOffset == caret - 1 &&
        newValue.text == oldValue.text.replaceRange(caret - 1, caret, "");
  }
}
