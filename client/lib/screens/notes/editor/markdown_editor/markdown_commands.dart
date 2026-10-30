import "package:flutter/services.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";

final _listMarker = RegExp(r"^(?:([-*+])|(\d{1,9})([.)]))[ \t]+");

const _indentUnit = "  ";

TextEditingValue? continueMarkdownLine(TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isValid) return null;
  final text = value.text.replaceRange(selection.start, selection.end, "");
  final caret = selection.start;
  final line = MarkdownSource.parse(text).lineAt(caret);
  if (line.block != null || caret < line.contentStart) return null;
  if (!line.isList && line.kind != MarkdownLineKind.quote) return null;
  if (text.substring(line.contentStart, line.end).trim().isEmpty && caret == line.end) {
    if (line.isList && line.level > 0) {
      return indentMarkdownLines(_collapsed(text, caret), outdent: true);
    }
    return _collapsed(text.replaceRange(line.start, line.end, ""), line.start);
  }
  final insertion = "\n${text.substring(line.start, line.markerStart)}${_nextMarker(text, line)}";
  return _collapsed(text.replaceRange(caret, caret, insertion), caret + insertion.length);
}

TextEditingValue? removeMarkdownMarker(TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isValid || !selection.isCollapsed) return null;
  final caret = selection.baseOffset;
  final line = MarkdownSource.parse(value.text).lineAt(caret);
  if (line.block != null || caret != line.contentStart || caret == line.start) return null;
  final start = line.hasMarker ? line.markerStart : line.start;
  final end = line.hasMarker ? line.contentStart : line.quoteEnd;
  return _collapsed(value.text.replaceRange(start, end, ""), start);
}

TextEditingValue? indentMarkdownLines(TextEditingValue value, {required bool outdent}) {
  final selection = value.selection;
  if (!selection.isValid) return null;
  final source = MarkdownSource.parse(value.text);
  final first = source.lineAt(selection.start);
  final last = source.lineAt(selection.end);
  final lines = source.lines.sublist(first.index, last.index + 1).where((line) => line.isList).toList();
  if (lines.isEmpty) return null;
  var text = value.text;
  var shiftBefore = 0;
  var shiftTotal = 0;
  for (final line in lines.reversed) {
    final change = outdent ? -_outdentWidth(text, line.quoteEnd) : _indentUnit.length;
    if (change == 0) continue;
    text = outdent
        ? text.replaceRange(line.quoteEnd, line.quoteEnd - change, "")
        : text.replaceRange(line.quoteEnd, line.quoteEnd, _indentUnit);
    shiftTotal += change;
    if (line.index == first.index) shiftBefore = change;
  }
  if (selection.isCollapsed) {
    final caret = (selection.baseOffset + shiftBefore).clamp(first.start, text.length);
    return _collapsed(text, caret);
  }
  return TextEditingValue(
    text: text,
    selection: TextSelection(baseOffset: first.start, extentOffset: (last.end + shiftTotal).clamp(0, text.length)),
  );
}

String _nextMarker(String text, MarkdownLine line) {
  if (line.kind == MarkdownLineKind.quote) return "";
  final match = _listMarker.firstMatch(text.substring(line.markerStart, line.contentStart))!;
  final marker = match.group(1) ?? "${int.parse(match.group(2)!) + 1}${match.group(3)}";
  return line.kind == MarkdownLineKind.task ? "$marker [ ] " : "$marker ";
}

int _outdentWidth(String text, int start) {
  if (start < text.length && text[start] == "\t") return 1;
  var width = 0;
  while (width < _indentUnit.length && start + width < text.length && text[start + width] == " ") {
    width++;
  }
  return width;
}

TextEditingValue _collapsed(String text, int offset) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: offset),
);
