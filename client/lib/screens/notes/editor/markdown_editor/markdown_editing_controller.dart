import "package:flutter/widgets.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_projection.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";

class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});

  static const _typingWindow = Duration(milliseconds: 800);
  static const _historyLimit = 200;

  final _undoStack = <_Snapshot>[];
  final _redoStack = <_Snapshot>[];
  final _typingOrigin = Object();
  _HistoryOptions? _pending;
  DateTime? _lastTyping;
  bool _restoring = false;
  MarkdownSource? _source;
  MarkdownPresentation? presentation;

  MarkdownSource get source {
    final cached = _source;
    if (cached != null && identical(cached.text, text)) return cached;
    return _source = MarkdownSource.parse(text);
  }

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  @override
  set value(TextEditingValue newValue) {
    final normalized = _normalize(newValue);
    if (normalized.text != value.text && !_restoring) _record();
    super.value = normalized;
  }

  void setValue(TextEditingValue value, {bool addToHistory = true, Object? origin, bool mergeWithPrevious = false}) {
    _pending = _HistoryOptions(addToHistory: addToHistory, origin: origin, mergeWithPrevious: mergeWithPrevious);
    try {
      this.value = value;
    } finally {
      _pending = null;
    }
  }

  void setText(String text, {TextSelection? selection, bool addToHistory = true}) => setValue(
    TextEditingValue(text: text, selection: selection ?? this.selection, composing: TextRange.empty),
    addToHistory: addToHistory,
  );

  void undo() {
    if (!canUndo) return;
    final snapshot = _undoStack.removeLast();
    _redoStack.add(_Snapshot(value, snapshot.origin));
    _restore(snapshot.value);
  }

  void redo() {
    if (!canRedo) return;
    final snapshot = _redoStack.removeLast();
    _undoStack.add(_Snapshot(value, snapshot.origin));
    _restore(snapshot.value);
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final presentation = this.presentation;
    if (presentation == null) return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    return MarkdownProjection(
      context: context,
      source: source,
      value: value,
      presentation: presentation,
      withComposing: withComposing,
    ).build(style);
  }

  void _record() {
    final options = _pending;
    if (options != null && !options.addToHistory) {
      _redoStack.clear();
      return;
    }
    final now = DateTime.now();
    final typing = options == null;
    final origin = typing ? _typingOrigin : options.origin;
    final merge = typing
        ? _lastTyping != null && now.difference(_lastTyping!) < _typingWindow
        : options.mergeWithPrevious;
    _lastTyping = typing ? now : null;
    final mergesWithPrevious = merge && origin != null && _undoStack.isNotEmpty && _undoStack.last.origin == origin;
    if (!mergesWithPrevious) {
      _undoStack.add(_Snapshot(value, origin));
      if (_undoStack.length > _historyLimit) _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void _restore(TextEditingValue snapshot) {
    _restoring = true;
    _lastTyping = null;
    try {
      value = snapshot;
    } finally {
      _restoring = false;
    }
  }

  static TextEditingValue _normalize(TextEditingValue value) {
    final length = value.text.length;
    final selection = value.selection;
    final composing = value.composing;
    return TextEditingValue(
      text: value.text,
      selection: selection.isValid
          ? selection.copyWith(
              baseOffset: selection.baseOffset.clamp(0, length),
              extentOffset: selection.extentOffset.clamp(0, length),
            )
          : selection,
      composing: composing.isValid && composing.isNormalized && composing.end <= length ? composing : TextRange.empty,
    );
  }
}

class _HistoryOptions {
  const _HistoryOptions({required this.addToHistory, required this.origin, required this.mergeWithPrevious});

  final bool addToHistory;
  final Object? origin;
  final bool mergeWithPrevious;
}

class _Snapshot {
  const _Snapshot(this.value, this.origin);

  final TextEditingValue value;
  final Object? origin;
}
