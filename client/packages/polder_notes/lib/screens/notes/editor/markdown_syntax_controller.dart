import "dart:typed_data";

import "package:flutter/material.dart";

import "package:polder/services/notes/note_link.dart";
import "package:polder/services/notes/note_markdown.dart";

class MarkdownSyntaxController extends TextEditingController {
  MarkdownSyntaxController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final base = style ?? DefaultTextStyle.of(context).style;
    if (withComposing && value.isComposingRangeValid && !value.composing.isCollapsed) {
      return super.buildTextSpan(context: context, style: base, withComposing: withComposing);
    }
    return _highlightMarkdown(text, base, Theme.of(context));
  }
}

abstract final class _MarkFlag {
  static const bold = 1 << 0;
  static const italic = 1 << 1;
  static const strike = 1 << 2;
  static const code = 1 << 3;
  static const syntax = 1 << 4;
  static const linkTitle = 1 << 5;
  static const linkTarget = 1 << 6;
  static const quote = 1 << 7;
  static const headingShift = 8;
}

final _lineBreak = RegExp(r"\r\n|\n|\r");
final _heading = RegExp(r"^( {0,3}#{1,6})([ \t]+|$)");
final _quote = RegExp(r"^( {0,3}>[ \t]?)+");
final _listMarker = RegExp(r"^([ \t]*)([-*+]|\d{1,9}[.)])([ \t]+)(\[[ xX]\][ \t]+)?");
final _callout = RegExp(r"^( {0,3}>[ \t]?)(\[![^\]]+\][+-]?)");
final _inlineCode = RegExp(r"(`+)(.+?)\1");
final _strong = RegExp(r"(\*\*|__)(?=\S)(.+?)(?<=\S)\1");
final _emphasis = RegExp(r"(?<![*_\w])([*_])(?=\S)(.+?)(?<=\S)\1(?![*_\w])");
final _strike = RegExp(r"(~~)(?=\S)(.+?)(?<=\S)~~");
final _link = RegExp(r"(!?\[)((?:[^\[\]\\]|\\.)*)(\]\()([^)\s]*(?:\s+\x22[^\x22]*\x22)?)(\))");
final _rule = RegExp(r"^ {0,3}([-*_])([ \t]*\1){2,}[ \t]*$");

TextSpan _highlightMarkdown(String text, TextStyle base, ThemeData theme) {
  final marks = Uint32List(text.length);
  void mark(int start, int end, int flag) {
    for (var i = start; i < end && i < marks.length; i++) {
      marks[i] |= flag;
    }
  }

  var offset = 0;
  String? fence;
  for (final line in _lines(text)) {
    final content = line.content;
    final start = offset;
    offset += line.length;

    final fenceMatch = markdownFenceLine.firstMatch(content);
    if (fence != null || fenceMatch != null) {
      mark(start, start + content.length, _MarkFlag.code);
      if (fenceMatch != null) {
        mark(start, start + fenceMatch.end, _MarkFlag.syntax);
        final marker = fenceMatch.group(1)!;
        if (fence == null) {
          fence = marker;
        } else if (marker[0] == fence[0] && marker.length >= fence.length && content.trim() == marker) {
          fence = null;
        }
      }
      continue;
    }

    if (_rule.hasMatch(content)) {
      mark(start, start + content.length, _MarkFlag.syntax);
      continue;
    }

    var bodyStart = 0;
    final heading = _heading.firstMatch(content);
    if (heading != null) {
      final level = heading.group(1)!.trim().length;
      mark(start, start + content.length, level << _MarkFlag.headingShift);
      mark(start, start + heading.end, _MarkFlag.syntax);
      bodyStart = heading.end;
    } else {
      final callout = _callout.firstMatch(content);
      final quote = _quote.firstMatch(content);
      if (quote != null) {
        mark(start, start + content.length, _MarkFlag.quote);
        mark(start, start + quote.end, _MarkFlag.syntax);
        bodyStart = quote.end;
      }
      if (callout != null) {
        mark(start + callout.start, start + callout.end, _MarkFlag.syntax);
        bodyStart = callout.end;
      }
      final list = _listMarker.firstMatch(content.substring(bodyStart));
      if (list != null) {
        mark(start + bodyStart, start + bodyStart + list.end, _MarkFlag.syntax);
        bodyStart += list.end;
      }
    }

    final body = content.substring(bodyStart);
    final bodyOffset = start + bodyStart;
    final codeSpans = <(int, int)>[];
    for (final match in _inlineCode.allMatches(body)) {
      final codeStart = bodyOffset + match.start;
      final fenceLength = match.group(1)!.length;
      mark(codeStart, bodyOffset + match.end, _MarkFlag.code);
      mark(codeStart, codeStart + fenceLength, _MarkFlag.syntax);
      mark(bodyOffset + match.end - fenceLength, bodyOffset + match.end, _MarkFlag.syntax);
      codeSpans.add((match.start, match.end));
    }
    bool inCode(Match match) => codeSpans.any((span) => match.start < span.$2 && match.end > span.$1);

    for (final match in _link.allMatches(body)) {
      if (inCode(match)) continue;
      var position = bodyOffset + match.start;
      for (final (group, flag) in [
        (1, _MarkFlag.syntax),
        (2, _MarkFlag.linkTitle),
        (3, _MarkFlag.syntax | _MarkFlag.linkTarget),
        (4, _MarkFlag.syntax | _MarkFlag.linkTarget),
        (5, _MarkFlag.syntax | _MarkFlag.linkTarget),
      ]) {
        final length = match.group(group)!.length;
        mark(position, position + length, flag);
        position += length;
      }
    }
    for (final (pattern, flag) in [
      (_strong, _MarkFlag.bold),
      (_strike, _MarkFlag.strike),
      (_emphasis, _MarkFlag.italic),
    ]) {
      for (final match in pattern.allMatches(body)) {
        if (inCode(match)) continue;
        final markerLength = match.group(1)!.length;
        final matchStart = bodyOffset + match.start;
        final matchEnd = bodyOffset + match.end;
        mark(matchStart, matchEnd, flag);
        mark(matchStart, matchStart + markerLength, _MarkFlag.syntax);
        mark(matchEnd - markerLength, matchEnd, _MarkFlag.syntax);
      }
    }
  }

  final styles = <int, TextStyle>{};
  final spans = <TextSpan>[];
  var runStart = 0;
  for (var i = 1; i <= text.length; i++) {
    if (i < text.length && marks[i] == marks[runStart]) continue;
    final flags = marks[runStart];
    spans.add(
      TextSpan(text: text.substring(runStart, i), style: styles.putIfAbsent(flags, () => _style(flags, base, theme))),
    );
    runStart = i;
  }
  return TextSpan(style: base, children: spans);
}

TextStyle _style(int flags, TextStyle base, ThemeData theme) {
  final colors = theme.colorScheme;
  var style = const TextStyle();
  final level = flags >> _MarkFlag.headingShift;
  if (level > 0) {
    final scale = const [1.0, 1.6, 1.4, 1.25, 1.12, 1.05, 1.0][level];
    style = style.copyWith(fontSize: (base.fontSize ?? 16) * scale, fontWeight: FontWeight.w600);
  }
  if (flags & _MarkFlag.bold != 0) style = style.copyWith(fontWeight: FontWeight.w700);
  if (flags & _MarkFlag.italic != 0) style = style.copyWith(fontStyle: FontStyle.italic);
  if (flags & _MarkFlag.strike != 0) style = style.copyWith(decoration: TextDecoration.lineThrough);
  if (flags & _MarkFlag.quote != 0) style = style.copyWith(color: colors.onSurfaceVariant);
  if (flags & _MarkFlag.code != 0) {
    style = monospaced(style).copyWith(backgroundColor: colors.surfaceContainerHighest);
  }
  if (flags & _MarkFlag.linkTitle != 0) style = style.copyWith(color: colors.primary);
  if (flags & _MarkFlag.syntax != 0) style = style.copyWith(color: colors.onSurfaceVariant.withValues(alpha: 0.55));
  if (flags & _MarkFlag.linkTarget != 0) {
    style = style.copyWith(
      fontSize: (style.fontSize ?? base.fontSize ?? 16) * 0.75,
      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
    );
  }
  return style;
}

class _Line {
  const _Line(this.content, this.length);

  final String content;
  final int length;
}

Iterable<_Line> _lines(String text) sync* {
  var start = 0;
  for (final match in _lineBreak.allMatches(text)) {
    yield _Line(text.substring(start, match.start), match.end - start);
    start = match.end;
  }
  yield _Line(text.substring(start), text.length - start);
}
