class ChecklistItem {
  const ChecklistItem(this.text, {this.checked = false});

  final String text;
  final bool checked;

  ChecklistItem copyWith({String? text, bool? checked}) =>
      ChecklistItem(text ?? this.text, checked: checked ?? this.checked);

  @override
  bool operator ==(Object other) => other is ChecklistItem && other.text == text && other.checked == checked;

  @override
  int get hashCode => Object.hash(text, checked);
}

abstract final class NoteChecklist {
  static const empty = "- [ ] ";

  static final _item = RegExp(r"^- \[([ xX])\](?: (.*))?$");
  static final _checkedTask = RegExp(r"^\s*(?:[-*+]|\d{1,9}[.)])\s+\[[xX]\]");
  static final _listMarker = RegExp(r"^\s*(?:[-*+]|\d{1,9}[.)])\s+(?:\[[ xX]\]\s*)?");

  static List<ChecklistItem>? parse(String text) {
    final lines = text.split("\n");
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
    if (lines.isEmpty) return null;
    final items = <ChecklistItem>[];
    for (final line in lines) {
      final match = _item.firstMatch(line);
      if (match == null) return null;
      items.add(ChecklistItem(match.group(2) ?? "", checked: match.group(1) != " "));
    }
    return items;
  }

  static bool isChecklist(String text) => parse(text) != null;

  static String serialize(List<ChecklistItem> items) => items.isEmpty
      ? empty
      : items.map((item) => "- [${item.checked ? "x" : " "}]${item.text.isEmpty ? "" : " ${item.text}"}").join("\n");

  static String fromText(String text) => serialize([
    for (final line in text.split("\n"))
      if (line.trim().isNotEmpty)
        ChecklistItem(line.replaceFirst(_listMarker, "").trim(), checked: _checkedTask.hasMatch(line)),
  ]);

  static String toText(List<ChecklistItem> items) => items.map((item) => item.text).join("\n");
}
