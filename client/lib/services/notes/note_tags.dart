import "package:polder/models/user_tag.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";

typedef _TagSpan = ({int start, int end, String name});

List<String> readNoteTags(String text) {
  final seen = <String>{};
  return [
    for (final span in _tagSpans(text))
      if (seen.add(tagKey(span.name))) span.name,
  ];
}

String appendNoteTag(String text, String name) {
  if (_tagSpans(text).any((span) => tagKey(span.name) == tagKey(name))) return text;
  final trimmed = text.trimRight();
  final lastLine = trimmed.substring(trimmed.lastIndexOf("\n") + 1);
  if (trimmed.isEmpty) return "#$name\n";
  if (_onlyTags(lastLine)) return "$trimmed #$name\n";
  return "$trimmed\n\n#$name\n";
}

String removeNoteTag(String text, String name) {
  final key = tagKey(name);
  final spans = _tagSpans(text).where((span) => tagKey(span.name) == key).toList();
  if (spans.isEmpty) return text;
  var kept = "";
  var position = 0;
  for (final span in spans) {
    kept += text.substring(position, span.start);
    var end = span.end;
    if (kept.endsWith(" ")) {
      kept = kept.substring(0, kept.length - 1);
    } else if (end < text.length && text[end] == " ") {
      end++;
    }
    if ((kept.isEmpty || kept.endsWith("\n")) && end < text.length && text[end] == "\n") end++;
    position = end;
  }
  final cleaned = (kept + text.substring(position)).trimRight();
  return cleaned.isNotEmpty && text.endsWith("\n") ? "$cleaned\n" : cleaned;
}

bool _onlyTags(String line) {
  final fields = line.trim().split(RegExp(r"\s+")).where((field) => field.isNotEmpty).toList();
  return fields.isNotEmpty && fields.every((field) => field.startsWith("#") && isValidTagName(field.substring(1)));
}

List<_TagSpan> _tagSpans(String text) {
  final source = MarkdownSource.parse(text);
  final spans = <_TagSpan>[];
  void collect(List<MarkdownInline> inlines) {
    for (final inline in inlines) {
      if (inline.kind == MarkdownInlineKind.tag) {
        spans.add((start: inline.start, end: inline.end, name: text.substring(inline.contentStart, inline.contentEnd)));
      } else if (inline.kind != MarkdownInlineKind.code && inline.kind != MarkdownInlineKind.link) {
        collect(inline.children);
      }
    }
  }

  for (final line in source.lines) {
    collect(source.inlinesOf(line));
  }
  return spans;
}
