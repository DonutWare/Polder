import "package:flutter/services.dart";

abstract final class FormatActions {
  static TextEditingValue wrap(TextEditingValue value, String marker, {String? closing}) {
    final end = closing ?? marker;
    final selection = _selection(value);
    final text = value.text;
    final before = text.substring(0, selection.start);
    final selected = text.substring(selection.start, selection.end);
    final after = text.substring(selection.end);
    if (before.endsWith(marker) && after.startsWith(end)) {
      return TextEditingValue(
        text: before.substring(0, before.length - marker.length) + selected + after.substring(end.length),
        selection: TextSelection(
          baseOffset: selection.start - marker.length,
          extentOffset: selection.end - marker.length,
        ),
      );
    }
    return TextEditingValue(
      text: "$before$marker$selected$end$after",
      selection: TextSelection(
        baseOffset: selection.start + marker.length,
        extentOffset: selection.end + marker.length,
      ),
    );
  }

  static TextEditingValue linePrefix(TextEditingValue value, String prefix) {
    final selection = _selection(value);
    final text = value.text;
    final lineStart = text.lastIndexOf("\n", selection.start == 0 ? 0 : selection.start - 1) + 1;
    var lineEnd = text.indexOf("\n", selection.end);
    if (lineEnd < 0) lineEnd = text.length;
    final lines = text.substring(lineStart, lineEnd).split("\n");
    bool alreadyHas(String line) {
      final existing = (_existingPrefix.firstMatch(line)?.group(0) ?? "").trim();
      if (prefix == "1. ") return _numbered.hasMatch(existing);
      return existing == prefix.trim();
    }

    final removing = lines.every(alreadyHas);
    var number = 1;
    final changed = [
      for (final line in lines)
        () {
          final existing = _existingPrefix.firstMatch(line)?.group(0) ?? "";
          final rest = line.substring(existing.length);
          if (removing) return rest;
          final applied = prefix == "1. " ? "${number++}. " : prefix;
          return "$applied$rest";
        }(),
    ].join("\n");
    final newText = text.replaceRange(lineStart, lineEnd, changed);
    final cursor = lineStart + changed.length;
    return TextEditingValue(
      text: newText,
      selection: selection.isCollapsed
          ? TextSelection.collapsed(offset: cursor)
          : TextSelection(baseOffset: lineStart, extentOffset: cursor),
    );
  }

  static final _numbered = RegExp(r"^\d{1,9}[.)]$");
  static final _existingPrefix = RegExp(r"^\s*(#{1,6}\s+|>\s?|[-*+]\s+\[[ xX]\]\s+|[-*+]\s+|\d{1,9}[.)]\s+)");

  static TextEditingValue insertBlock(TextEditingValue value, String snippet, {int? cursorAt}) {
    final selection = _selection(value);
    final text = value.text;
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);
    final lead = before.isEmpty || before.endsWith("\n\n") ? "" : (before.endsWith("\n") ? "\n" : "\n\n");
    final trail = after.isEmpty || after.startsWith("\n\n") ? "" : (after.startsWith("\n") ? "\n" : "\n\n");
    final start = before.length + lead.length;
    return TextEditingValue(
      text: "$before$lead$snippet$trail$after",
      selection: TextSelection.collapsed(offset: start + (cursorAt ?? snippet.length)),
    );
  }

  static TextEditingValue insert(TextEditingValue value, String inserted) {
    final selection = _selection(value);
    return TextEditingValue(
      text: value.text.replaceRange(selection.start, selection.end, inserted),
      selection: TextSelection.collapsed(offset: selection.start + inserted.length),
    );
  }

  static TextEditingValue? takeLinkTrigger(TextEditingValue value, String previousText) {
    final cursor = value.selection.baseOffset;
    if (!value.selection.isCollapsed || cursor < 2 || value.text.length != previousText.length + 1) return null;
    if (value.text.substring(cursor - 2, cursor) != "[[") return null;
    return TextEditingValue(
      text: value.text.replaceRange(cursor - 2, cursor, ""),
      selection: TextSelection.collapsed(offset: cursor - 2),
    );
  }

  static TextSelection _selection(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid) return TextSelection.collapsed(offset: value.text.length);
    return TextSelection(
      baseOffset: selection.start.clamp(0, value.text.length),
      extentOffset: selection.end.clamp(0, value.text.length),
    );
  }
}
