import "dart:math" as math;

import "package:flutter/material.dart";

import "package:polder/models/user_tag.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor_style.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/services/notes/note_markdown.dart";

typedef MarkdownBlockBuilder = Widget? Function(BuildContext context, MarkdownBlock block, String source);

class MarkdownPresentation {
  const MarkdownPresentation({
    required this.style,
    required this.width,
    required this.focused,
    required this.imageFor,
    required this.onImageTap,
    required this.onToggleTask,
    required this.onRevealBlock,
    this.blockBuilder,
    this.tagColor = _noTagColor,
  });

  static Color? _noTagColor(String key) => null;

  final MarkdownEditorStyle style;
  final double width;
  final bool focused;
  final ImageProvider Function(String destination) imageFor;
  final void Function(String destination) onImageTap;
  final void Function(MarkdownLine line) onToggleTask;
  final void Function(MarkdownBlock block) onRevealBlock;
  final MarkdownBlockBuilder? blockBuilder;
  final Color? Function(String key) tagColor;
}

String unescapeMarkdown(String value) =>
    value.replaceAllMapped(RegExp(r"\\([!-/:-@\[-`{-~])"), (match) => match.group(1)!);

bool rendersAsEmbed(String text, MarkdownInline node, MarkdownLine line) =>
    node.kind == MarkdownInlineKind.link &&
    node.start == line.contentStart &&
    node.end == line.end &&
    isVideoDestination(markdownDestination(text, node));

String markdownDestination(String text, MarkdownInline node) => node.kind == MarkdownInlineKind.url
    ? text.substring(node.start, node.end)
    : unescapeMarkdown(text.substring(node.destinationStart!, node.destinationEnd!));

class MarkdownProjection {
  MarkdownProjection({
    required this.context,
    required this.source,
    required this.value,
    required this.presentation,
    required this.withComposing,
  });

  static const _caretMargin = 4.0;
  static const _trailingLineAnchor = "\u200B";
  static const _maxImageHeight = 360.0;
  static const _hidden = TextStyle(
    fontSize: 0.01,
    color: Colors.transparent,
    backgroundColor: Colors.transparent,
    letterSpacing: 0,
    wordSpacing: 0,
    decoration: TextDecoration.none,
  );

  final BuildContext context;
  final MarkdownSource source;
  final TextEditingValue value;
  final MarkdownPresentation presentation;
  final bool withComposing;
  final _spans = <InlineSpan>[];

  String get _text => source.text;

  MarkdownEditorStyle get _style => presentation.style;

  double get _slotWidth => math.max(0, presentation.width - _caretMargin);

  TextSpan build(TextStyle? base) {
    final body = (base ?? const TextStyle()).merge(_style.body);
    final lines = source.lines;
    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      final block = line.block;
      if (block == null) {
        final style = _lineStyle(line, body);
        _line(line, style);
        _newlineAfter(line, style);
        index++;
        continue;
      }
      _block(block, body);
      while (index < lines.length && lines[index].block == block) {
        index++;
      }
      _newlineAfter(lines[index - 1], body);
    }
    if (_text.endsWith("\n")) _spans.add(TextSpan(text: _trailingLineAnchor, style: body));
    return TextSpan(style: body, children: _spans);
  }

  bool _touches(int start, int end) {
    final composing = value.composing;
    if (withComposing && composing.isValid && !composing.isCollapsed) {
      if (composing.start <= end && composing.end >= start) return true;
    }
    final selection = value.selection;
    return presentation.focused && selection.isValid && selection.start <= end && selection.end >= start;
  }

  bool _markerActive(MarkdownLine line) => _touches(line.markerStart, line.contentStart - 1);

  TextStyle _lineStyle(MarkdownLine line, TextStyle body) =>
      line.kind == MarkdownLineKind.heading ? _style.heading(body, line.level) : body;

  void _newlineAfter(MarkdownLine line, TextStyle style) {
    if (line.end < _text.length) _emit(line.end, line.end + 1, style);
  }

  void _emit(int start, int end, TextStyle style) {
    if (start < end) _spans.add(TextSpan(text: _text.substring(start, end), style: style));
  }

  void _hide(int start, int end) => _emit(start, end, _hidden);

  void _marker(int start, int end, TextStyle style, bool active) =>
      active ? _emit(start, end, _style.syntax(style)) : _hide(start, end);

  void _widget(Widget child, PlaceholderAlignment alignment) =>
      _spans.add(WidgetSpan(child: child, alignment: alignment));

  void _line(MarkdownLine line, TextStyle style) {
    final active = _touches(line.start, line.end);
    _quotePrefix(line, style, active);
    _emit(line.quoteEnd, line.markerStart, style);
    var content = style;
    switch (line.kind) {
      case MarkdownLineKind.heading:
        _marker(line.markerStart, line.contentStart, style, active);
      case MarkdownLineKind.bullet:
        if (_markerActive(line)) {
          _emit(line.markerStart, line.contentStart, _style.syntax(style));
        } else {
          _spans.add(
            TextSpan(
              text: "•",
              style: style.copyWith(color: _style.syntaxColor),
            ),
          );
          _emit(line.markerStart + 1, line.contentStart, style);
        }
      case MarkdownLineKind.ordered:
        _emit(line.markerStart, line.contentStart, style);
      case MarkdownLineKind.task:
        final box = line.checkbox!;
        final checked = _text[box + 1] != " ";
        if (_markerActive(line)) {
          _emit(line.markerStart, line.contentStart, _style.syntax(style));
        } else {
          _hide(line.markerStart, box);
          _widget(_checkbox(line, checked, style), PlaceholderAlignment.middle);
          _hide(box + 1, box + 3);
          _emit(box + 3, line.contentStart, style);
        }
        if (checked) {
          content = style.copyWith(
            color: _style.syntaxColor,
            decoration: TextDecoration.lineThrough,
            decorationColor: _style.syntaxColor,
          );
        }
      case MarkdownLineKind.paragraph || MarkdownLineKind.quote:
        break;
    }
    _inlines(source.inlinesOf(line), line.contentStart, line.end, content, line);
  }

  void _quotePrefix(MarkdownLine line, TextStyle style, bool active) {
    if (line.quoteEnd == line.start) return;
    if (active) {
      _emit(line.start, line.quoteEnd, _style.syntax(style));
      return;
    }
    final bar = style.copyWith(color: _style.quoteColor, fontWeight: FontWeight.w900);
    for (var index = line.start; index < line.quoteEnd; index++) {
      if (_text[index] == ">") {
        _spans.add(TextSpan(text: "▍", style: bar));
      } else {
        _emit(index, index + 1, style);
      }
    }
  }

  void _inlines(List<MarkdownInline> nodes, int from, int to, TextStyle style, MarkdownLine line) {
    var cursor = from;
    for (final node in nodes) {
      _emit(cursor, node.start, style);
      _inline(node, style, line);
      cursor = node.end;
    }
    _emit(cursor, to, style);
  }

  void _inline(MarkdownInline node, TextStyle style, MarkdownLine line) {
    final active = _touches(node.start, node.end);
    switch (node.kind) {
      case MarkdownInlineKind.escape:
        _marker(node.start, node.contentStart, style, active);
        _emit(node.contentStart, node.end, style);
      case MarkdownInlineKind.code:
        final code = _style.codeOf(style);
        _marker(node.start, node.contentStart, code, active);
        _emit(node.contentStart, node.contentEnd, code);
        _marker(node.contentEnd, node.end, code, active);
      case MarkdownInlineKind.url:
        _emit(node.start, node.end, _style.linkOf(style));
      case MarkdownInlineKind.tag:
        _emit(node.start, node.end, _tagStyle(style, _text.substring(node.contentStart, node.contentEnd)));
      case MarkdownInlineKind.link when !active && rendersAsEmbed(_text, node, line):
        _widget(_image(node, style, standalone: true), PlaceholderAlignment.bottom);
        _hide(node.start + 1, node.end);
      case MarkdownInlineKind.link:
        _marker(node.start, node.contentStart, style, active);
        _inlines(node.children, node.contentStart, node.contentEnd, _style.linkOf(style), line);
        _marker(node.contentEnd, node.end, style, active);
      case MarkdownInlineKind.image:
        if (active) {
          _emit(node.start, node.contentStart, _style.syntax(style));
          _emit(node.contentStart, node.contentEnd, style);
          _emit(node.contentEnd, node.end, _style.syntax(style));
        } else {
          final standalone = _isStandalone(node, line);
          _widget(
            _image(node, style, standalone: standalone),
            standalone ? PlaceholderAlignment.bottom : PlaceholderAlignment.middle,
          );
          _hide(node.start + 1, node.end);
        }
      case MarkdownInlineKind.strong ||
          MarkdownInlineKind.emphasis ||
          MarkdownInlineKind.strikethrough ||
          MarkdownInlineKind.highlight:
        final inner = _decorated(style, node.kind);
        _marker(node.start, node.contentStart, inner, active);
        _inlines(node.children, node.contentStart, node.contentEnd, inner, line);
        _marker(node.contentEnd, node.end, inner, active);
    }
  }

  TextStyle _tagStyle(TextStyle style, String name) {
    final color = presentation.tagColor(tagKey(name)) ?? _style.accentColor;
    return style.copyWith(color: color, fontWeight: FontWeight.w600, backgroundColor: color.withValues(alpha: 0.12));
  }

  bool _isStandalone(MarkdownInline node, MarkdownLine line) => node.start == line.contentStart && node.end == line.end;

  TextStyle _decorated(TextStyle style, MarkdownInlineKind kind) => switch (kind) {
    MarkdownInlineKind.strong => style.copyWith(fontWeight: FontWeight.w700),
    MarkdownInlineKind.emphasis => style.copyWith(fontStyle: FontStyle.italic),
    MarkdownInlineKind.strikethrough => style.copyWith(
      decoration: TextDecoration.combine([if (style.decoration != null) style.decoration!, TextDecoration.lineThrough]),
    ),
    MarkdownInlineKind.highlight => style.copyWith(backgroundColor: _style.highlightColor),
    _ => style,
  };

  Widget _checkbox(MarkdownLine line, bool checked, TextStyle style) {
    final size = (style.fontSize ?? 14) * 1.2;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => presentation.onToggleTask(line),
        child: Icon(
          checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: size,
          color: checked ? _style.accentColor : _style.syntaxColor,
        ),
      ),
    );
  }

  Widget _image(MarkdownInline node, TextStyle style, {required bool standalone}) {
    final destination = markdownDestination(_text, node);
    final alt = _text.substring(node.contentStart, node.contentEnd);
    final fallback = _MediaChip(label: alt.isNotEmpty ? alt : _basename(destination), style: style, colors: _style);
    final video = isVideoDestination(destination);
    final picture = Image(
      image: presentation.imageFor(destination),
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      semanticLabel: alt,
      errorBuilder: (_, _, _) => fallback,
    );
    final image = NotePlayOverlay(
      visible: video && standalone,
      child: ClipRRect(borderRadius: notePreviewRadius, child: picture),
    );
    final lineHeight = (style.fontSize ?? 14) * 1.5;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => presentation.onImageTap(destination),
        child: standalone
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _slotWidth, maxHeight: _maxImageHeight),
                child: image,
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _slotWidth, maxHeight: lineHeight),
                child: image,
              ),
      ),
    );
  }

  void _block(MarkdownBlock block, TextStyle body) {
    final raw = _text.substring(block.start, block.end);
    final rendered = _touches(block.start, block.end) ? null : _renderedBlock(block, raw, body);
    if (rendered == null) {
      _rawBlock(block, body);
      return;
    }
    _widget(rendered, PlaceholderAlignment.middle);
    _hide(block.start + 1, block.end);
  }

  Widget? _renderedBlock(MarkdownBlock block, String raw, TextStyle body) {
    final child = block.kind == MarkdownBlockKind.rule
        ? Divider(height: (body.fontSize ?? 14) * (body.height ?? 1.2), color: _style.syntaxColor)
        : presentation.blockBuilder?.call(context, block, raw);
    if (child == null) return null;
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => presentation.onRevealBlock(block),
        child: SizedBox(width: _slotWidth, child: child),
      ),
    );
  }

  void _rawBlock(MarkdownBlock block, TextStyle body) {
    if (block.kind != MarkdownBlockKind.code) {
      _emit(block.start, block.end, block.kind == MarkdownBlockKind.rule ? _style.syntax(body) : body);
      return;
    }
    final code = body.merge(_style.code);
    final lines = source.lines.where((line) => line.block == block).toList();
    for (final line in lines) {
      final fence = line == lines.first || (line == lines.last && lines.length > 1);
      _emit(line.start, line.end, fence ? _style.syntax(code) : code);
      if (line != lines.last) _emit(line.end, line.end + 1, code);
    }
  }

  static String _basename(String destination) {
    final path = destination.split(RegExp(r"[?#]")).first;
    return Uri.decodeComponent(path.substring(path.lastIndexOf("/") + 1));
  }
}

class _MediaChip extends StatelessWidget {
  const _MediaChip({required this.label, required this.style, required this.colors});

  final String label;
  final TextStyle style;
  final MarkdownEditorStyle colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: colors.codeBackground, borderRadius: notePreviewRadius),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file_outlined, size: style.fontSize, color: colors.syntaxColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.copyWith(height: 1.2)),
        ),
      ],
    ),
  );
}
