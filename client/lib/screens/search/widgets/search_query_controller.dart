import "package:flutter/material.dart";

import "package:polder/util/search_syntax.dart";

class SearchQueryController extends TextEditingController {
  SearchQueryController({super.text});

  List<TextRange> _warnings = const [];

  set warnings(List<TextRange> ranges) {
    if (_sameRanges(ranges, _warnings)) return;
    _warnings = ranges;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    final cs = Theme.of(context).colorScheme;
    final tagStyle = TextStyle(color: cs.primary, fontWeight: FontWeight.w600);
    final valueStyle = TextStyle(color: cs.tertiary);
    final warningStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
      decorationColor: cs.error,
    );

    final styled = <(TextRange, TextStyle)>[];
    for (final token in tokenizeSearch(text)) {
      if (!token.isFilter) continue;
      final keyEnd = token.range.start + token.filterLength;
      styled
        ..add((TextRange(start: token.range.start, end: keyEnd), tagStyle))
        ..add((TextRange(start: keyEnd, end: token.range.end), valueStyle));
    }
    final warnings = [
      for (final range in _warnings)
        if (range.end <= text.length) range,
    ];

    final boundaries = <int>{0, text.length};
    for (final (range, _) in styled) {
      boundaries.addAll([range.start, range.end]);
    }
    for (final range in warnings) {
      boundaries.addAll([range.start, range.end]);
    }
    final points = boundaries.toList()..sort();
    final children = <TextSpan>[];
    for (var i = 0; i < points.length - 1; i++) {
      final (start, end) = (points[i], points[i + 1]);
      if (start == end) continue;
      TextStyle? segment;
      for (final (range, rangeStyle) in styled) {
        if (range.start <= start && end <= range.end) segment = rangeStyle;
      }
      if (warnings.any((range) => range.start <= start && end <= range.end)) {
        segment = (segment ?? const TextStyle()).merge(warningStyle);
      }
      children.add(TextSpan(text: text.substring(start, end), style: segment));
    }
    return TextSpan(style: style, children: children);
  }
}

bool _sameRanges(List<TextRange> a, List<TextRange> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
