import "package:flutter/material.dart";

class MarkdownEditorStyle {
  const MarkdownEditorStyle({
    required this.body,
    required this.code,
    required this.link,
    required this.syntaxColor,
    required this.accentColor,
    required this.quoteColor,
    required this.highlightColor,
    required this.codeBackground,
  });

  static const _headingScales = [1.75, 1.5, 1.3, 1.15, 1.05, 1.0];

  final TextStyle body;
  final TextStyle code;
  final TextStyle link;
  final Color syntaxColor;
  final Color accentColor;
  final Color quoteColor;
  final Color highlightColor;
  final Color codeBackground;

  TextStyle heading(TextStyle base, int level) => base.copyWith(
    fontSize: (base.fontSize ?? 14) * _headingScales[(level - 1).clamp(0, _headingScales.length - 1)],
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  TextStyle syntax(TextStyle base) => base.copyWith(color: syntaxColor);

  TextStyle codeOf(TextStyle base) => base.merge(code).copyWith(backgroundColor: codeBackground);

  TextStyle linkOf(TextStyle base) => base.merge(link);
}
