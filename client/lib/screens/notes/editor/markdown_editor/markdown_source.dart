enum MarkdownLineKind { paragraph, heading, bullet, ordered, task, quote }

enum MarkdownBlockKind { code, table, callout, rule }

enum MarkdownInlineKind { strong, emphasis, strikethrough, highlight, code, link, image, url, escape }

class MarkdownLine {
  const MarkdownLine({
    required this.index,
    required this.start,
    required this.end,
    required this.kind,
    required this.quoteEnd,
    required this.markerStart,
    required this.contentStart,
    this.level = 0,
    this.checkbox,
    this.block,
  });

  final int index;
  final int start;
  final int end;
  final MarkdownLineKind kind;
  final int quoteEnd;
  final int markerStart;
  final int contentStart;
  final int level;
  final int? checkbox;
  final MarkdownBlock? block;

  bool get hasMarker => markerStart < contentStart;

  bool get isList =>
      kind == MarkdownLineKind.bullet || kind == MarkdownLineKind.ordered || kind == MarkdownLineKind.task;
}

class MarkdownBlock {
  const MarkdownBlock({required this.kind, required this.start, required this.end, required this.firstLine});

  final MarkdownBlockKind kind;
  final int start;
  final int end;
  final int firstLine;
}

class MarkdownInline {
  const MarkdownInline({
    required this.kind,
    required this.start,
    required this.end,
    required this.contentStart,
    required this.contentEnd,
    this.destinationStart,
    this.destinationEnd,
    this.children = const [],
  });

  final MarkdownInlineKind kind;
  final int start;
  final int end;
  final int contentStart;
  final int contentEnd;
  final int? destinationStart;
  final int? destinationEnd;
  final List<MarkdownInline> children;

  bool contains(int offset) => offset >= start && offset < end;
}

class MarkdownSource {
  MarkdownSource._(this.text, this.lines, this.blocks);

  factory MarkdownSource.parse(String text) {
    final ranges = _lineRanges(text);
    final lines = <MarkdownLine>[];
    final blocks = <MarkdownBlock>[];
    var index = 0;
    while (index < ranges.length) {
      final block = _blockAt(text, ranges, index);
      if (block == null) {
        lines.add(_line(text, index, ranges[index]));
        index++;
        continue;
      }
      final (kind, lastLine) = block;
      final parsed = MarkdownBlock(kind: kind, start: ranges[index].$1, end: ranges[lastLine].$2, firstLine: index);
      blocks.add(parsed);
      for (var line = index; line <= lastLine; line++) {
        final (start, end) = ranges[line];
        lines.add(
          MarkdownLine(
            index: line,
            start: start,
            end: end,
            kind: MarkdownLineKind.paragraph,
            quoteEnd: start,
            markerStart: start,
            contentStart: start,
            block: parsed,
          ),
        );
      }
      index = lastLine + 1;
    }
    return MarkdownSource._(text, List.unmodifiable(lines), List.unmodifiable(blocks));
  }

  final String text;
  final List<MarkdownLine> lines;
  final List<MarkdownBlock> blocks;
  final _inlines = <int, List<MarkdownInline>>{};

  MarkdownLine lineAt(int offset) {
    var low = 0;
    var high = lines.length - 1;
    while (low < high) {
      final middle = (low + high + 1) ~/ 2;
      if (lines[middle].start <= offset) {
        low = middle;
      } else {
        high = middle - 1;
      }
    }
    return lines[low];
  }

  List<MarkdownInline> inlinesOf(MarkdownLine line) =>
      _inlines[line.index] ??= line.block == null ? parseInlines(text, line.contentStart, line.end) : const [];

  MarkdownInline? inlineAt(int offset, bool Function(MarkdownInline inline) test) {
    MarkdownInline? search(List<MarkdownInline> nodes) {
      for (final node in nodes) {
        if (!node.contains(offset)) continue;
        if (test(node)) return node;
        return search(node.children);
      }
      return null;
    }

    return search(inlinesOf(lineAt(offset)));
  }
}

List<(int, int)> _lineRanges(String text) {
  final ranges = <(int, int)>[];
  var start = 0;
  while (true) {
    final newline = text.indexOf("\n", start);
    if (newline < 0) {
      ranges.add((start, text.length));
      return ranges;
    }
    ranges.add((start, newline));
    start = newline + 1;
  }
}

final _fence = RegExp(r"^ {0,3}(`{3,}|~{3,})");
final _calloutHeader = RegExp(r"^ {0,3}>[ \t]?\[![^\]\s]+\]");
final _quoteLine = RegExp(r"^ {0,3}>");
final _tableDelimiter = RegExp(r"^ *\|? *:?-+:? *(\| *:?-+:? *)*\|? *$");
final _rule = RegExp(r"^ {0,3}([-*_])( *\1){2,} *$");
final _quotePrefix = RegExp(r"^(?: {0,3}>[ \t]?)+");
final _heading = RegExp(r"^(#{1,6})(?:[ \t]+|$)");
final _task = RegExp(r"^([ \t]*)(?:[-*+]|\d{1,9}[.)])[ \t]+(\[[ xX]\])(?:[ \t]+|$)");
final _bullet = RegExp(r"^([ \t]*)[-*+](?:[ \t]+|$)");
final _ordered = RegExp(r"^([ \t]*)\d{1,9}[.)](?:[ \t]+|$)");

(MarkdownBlockKind, int)? _blockAt(String text, List<(int, int)> ranges, int index) {
  String line(int i) => text.substring(ranges[i].$1, ranges[i].$2);
  final first = line(index);
  final fence = _fence.firstMatch(first);
  if (fence != null) {
    final marker = fence.group(1)!;
    final closer = RegExp("^ {0,3}${RegExp.escape(marker[0])}{${marker.length},} *\$");
    for (var i = index + 1; i < ranges.length; i++) {
      if (closer.hasMatch(line(i))) return (MarkdownBlockKind.code, i);
    }
    return (MarkdownBlockKind.code, ranges.length - 1);
  }
  if (_calloutHeader.hasMatch(first)) {
    var last = index;
    while (last + 1 < ranges.length && _quoteLine.hasMatch(line(last + 1))) {
      last++;
    }
    return (MarkdownBlockKind.callout, last);
  }
  if (first.contains("|") && index + 1 < ranges.length) {
    final delimiter = line(index + 1);
    if (_tableDelimiter.hasMatch(delimiter) && delimiter.contains("-")) {
      var last = index + 1;
      while (last + 1 < ranges.length && line(last + 1).contains("|") && line(last + 1).trim().isNotEmpty) {
        last++;
      }
      return (MarkdownBlockKind.table, last);
    }
  }
  final previousBlank = index == 0 || line(index - 1).trim().isEmpty;
  if (previousBlank && _rule.hasMatch(first)) return (MarkdownBlockKind.rule, index);
  return null;
}

MarkdownLine _line(String text, int index, (int, int) range) {
  final (start, end) = range;
  final content = text.substring(start, end);
  final quote = _quotePrefix.firstMatch(content);
  final quoteEnd = start + (quote?.end ?? 0);
  final rest = text.substring(quoteEnd, end);
  MarkdownLine build(MarkdownLineKind kind, {int markerStart = -1, int contentStart = -1, int level = 0, int? box}) =>
      MarkdownLine(
        index: index,
        start: start,
        end: end,
        kind: kind,
        quoteEnd: quoteEnd,
        markerStart: markerStart < 0 ? quoteEnd : markerStart,
        contentStart: contentStart < 0 ? quoteEnd : contentStart,
        level: level,
        checkbox: box,
      );

  if (_heading.firstMatch(rest) case final match?) {
    return build(MarkdownLineKind.heading, contentStart: quoteEnd + match.end, level: match.group(1)!.length);
  }
  if (_task.firstMatch(rest) case final match?) {
    final indent = match.group(1)!.length;
    return build(
      MarkdownLineKind.task,
      markerStart: quoteEnd + indent,
      contentStart: quoteEnd + match.end,
      level: indent,
      box: quoteEnd + match.group(0)!.indexOf(match.group(2)!, indent),
    );
  }
  if (_bullet.firstMatch(rest) case final match?) {
    final indent = match.group(1)!.length;
    return build(
      MarkdownLineKind.bullet,
      markerStart: quoteEnd + indent,
      contentStart: quoteEnd + match.end,
      level: indent,
    );
  }
  if (_ordered.firstMatch(rest) case final match?) {
    final indent = match.group(1)!.length;
    return build(
      MarkdownLineKind.ordered,
      markerStart: quoteEnd + indent,
      contentStart: quoteEnd + match.end,
      level: indent,
    );
  }
  return build(quote == null ? MarkdownLineKind.paragraph : MarkdownLineKind.quote);
}

const _delimiters = ["**", "__", "~~", "==", "*", "_"];

const _delimiterKinds = {
  "**": MarkdownInlineKind.strong,
  "__": MarkdownInlineKind.strong,
  "~~": MarkdownInlineKind.strikethrough,
  "==": MarkdownInlineKind.highlight,
  "*": MarkdownInlineKind.emphasis,
  "_": MarkdownInlineKind.emphasis,
};

List<MarkdownInline> parseInlines(String text, int from, int to) {
  final nodes = <MarkdownInline>[];
  var index = from;
  while (index < to) {
    final node = _inlineAt(text, index, from, to);
    if (node == null) {
      index++;
    } else {
      nodes.add(node);
      index = node.end;
    }
  }
  return nodes;
}

MarkdownInline? _inlineAt(String text, int index, int from, int to) {
  final char = text[index];
  if (char == r"\" && index + 1 < to && _isPunctuation(text.codeUnitAt(index + 1))) {
    return MarkdownInline(
      kind: MarkdownInlineKind.escape,
      start: index,
      end: index + 2,
      contentStart: index + 1,
      contentEnd: index + 2,
    );
  }
  if (char == "`") return _codeSpan(text, index, to);
  if (char == "!" && index + 1 < to && text[index + 1] == "[") return _link(text, index, to, image: true);
  if (char == "[") return _link(text, index, to, image: false);
  if (char == "h" && (index == from || !_isWord(text.codeUnitAt(index - 1)))) {
    final url = _url(text, index, to);
    if (url != null) return url;
  }
  for (final delimiter in _delimiters) {
    if (!text.startsWith(delimiter, index)) continue;
    final node = _delimited(text, delimiter, index, from, to);
    if (node != null) return node;
    if (delimiter.length == 2) continue;
    return null;
  }
  return null;
}

MarkdownInline? _codeSpan(String text, int index, int to) {
  var run = 0;
  while (index + run < to && text[index + run] == "`") {
    run++;
  }
  var search = index + run;
  while (search < to) {
    final close = text.indexOf("`" * run, search);
    if (close < 0 || close + run > to) return null;
    var closeRun = 0;
    while (close + closeRun < to && text[close + closeRun] == "`") {
      closeRun++;
    }
    if (closeRun == run) {
      if (close == index + run) return null;
      return MarkdownInline(
        kind: MarkdownInlineKind.code,
        start: index,
        end: close + run,
        contentStart: index + run,
        contentEnd: close,
      );
    }
    search = close + closeRun;
  }
  return null;
}

MarkdownInline? _link(String text, int index, int to, {required bool image}) {
  final open = image ? index + 1 : index;
  final close = _closingBracket(text, open, to);
  if (close == null || close + 1 >= to || text[close + 1] != "(") return null;
  final destination = _destination(text, close + 2, to);
  if (destination == null) return null;
  final (destinationStart, destinationEnd, end) = destination;
  return MarkdownInline(
    kind: image ? MarkdownInlineKind.image : MarkdownInlineKind.link,
    start: index,
    end: end,
    contentStart: open + 1,
    contentEnd: close,
    destinationStart: destinationStart,
    destinationEnd: destinationEnd,
    children: image ? const [] : parseInlines(text, open + 1, close),
  );
}

int? _closingBracket(String text, int open, int to) {
  var depth = 0;
  for (var i = open; i < to; i++) {
    final char = text[i];
    if (char == r"\") {
      i++;
    } else if (char == "[") {
      depth++;
    } else if (char == "]") {
      depth--;
      if (depth == 0) return i;
    }
  }
  return null;
}

(int, int, int)? _destination(String text, int start, int to) {
  var index = start;
  while (index < to && text[index] == " ") {
    index++;
  }
  if (index < to && text[index] == "<") {
    final close = text.indexOf(">", index);
    if (close < 0 || close >= to) return null;
    final end = text.indexOf(")", close);
    if (end < 0 || end >= to) return null;
    return (index + 1, close, end + 1);
  }
  final destinationStart = index;
  var depth = 0;
  while (index < to) {
    final char = text[index];
    if (char == r"\") {
      index += 2;
      continue;
    }
    if (char == " " || char == "\t") break;
    if (char == "(") depth++;
    if (char == ")") {
      if (depth == 0) return (destinationStart, index, index + 1);
      depth--;
    }
    index++;
  }
  final destinationEnd = index;
  final end = text.indexOf(")", index);
  if (end < 0 || end >= to) return null;
  return (destinationStart, destinationEnd, end + 1);
}

MarkdownInline? _url(String text, int index, int to) {
  if (!text.startsWith("http://", index) && !text.startsWith("https://", index)) return null;
  var end = index;
  while (end < to && !_isSpace(text.codeUnitAt(end)) && text[end] != "<") {
    end++;
  }
  while (end > index && ".,;:!?\"')]*_~".contains(text[end - 1])) {
    end--;
  }
  if (text.indexOf("://", index) + 3 >= end) return null;
  return MarkdownInline(kind: MarkdownInlineKind.url, start: index, end: end, contentStart: index, contentEnd: end);
}

MarkdownInline? _delimited(String text, String delimiter, int index, int from, int to) {
  final contentStart = index + delimiter.length;
  if (contentStart >= to || _isSpace(text.codeUnitAt(contentStart))) return null;
  final intraword = delimiter.startsWith("_");
  if (intraword && index > from && _isWord(text.codeUnitAt(index - 1))) return null;
  final close = _closer(text, delimiter, contentStart, to);
  if (close == null) return null;
  final end = close + delimiter.length;
  if (intraword && end < to && _isWord(text.codeUnitAt(end))) return null;
  return MarkdownInline(
    kind: _delimiterKinds[delimiter]!,
    start: index,
    end: end,
    contentStart: contentStart,
    contentEnd: close,
    children: parseInlines(text, contentStart, close),
  );
}

int? _closer(String text, String delimiter, int start, int to) {
  var index = start;
  while (index < to) {
    final char = text[index];
    if (char == r"\") {
      index += 2;
      continue;
    }
    if (char == "`") {
      final code = _codeSpan(text, index, to);
      index = code?.end ?? index + 1;
      continue;
    }
    if (delimiter.length == 1 && _startsWithin(text, delimiter * 2, index, to)) {
      final nested = _closer(text, delimiter * 2, index + 2, to);
      if (nested != null) {
        index = nested + 2;
        continue;
      }
    }
    if (_startsWithin(text, delimiter, index, to) &&
        index > start &&
        !_isSpace(text.codeUnitAt(index - 1)) &&
        (delimiter.length == 2 || !_startsWithin(text, delimiter * 2, index, to))) {
      var run = delimiter.length;
      while (index + run < to && text[index + run] == delimiter[0]) {
        run++;
      }
      return index + run - delimiter.length;
    }
    index++;
  }
  return null;
}

bool _startsWithin(String text, String pattern, int index, int to) =>
    index + pattern.length <= to && text.startsWith(pattern, index);

bool _isSpace(int unit) => unit == 0x20 || unit == 0x09 || unit == 0x0a || unit == 0x0d;

bool _isWord(int unit) =>
    (unit >= 0x30 && unit <= 0x39) || (unit >= 0x41 && unit <= 0x5a) || (unit >= 0x61 && unit <= 0x7a) || unit > 0x7f;

bool _isPunctuation(int unit) =>
    (unit >= 0x21 && unit <= 0x2f) ||
    (unit >= 0x3a && unit <= 0x40) ||
    (unit >= 0x5b && unit <= 0x60) ||
    (unit >= 0x7b && unit <= 0x7e);
