import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "package:markdown/markdown.dart" as md;
import "package:re_highlight/languages/all.dart";
import "package:re_highlight/re_highlight.dart";
import "package:re_highlight/styles/github-dark.dart";
import "package:re_highlight/styles/github.dart";

import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/services/notes/note_markdown.dart";

class ReadOnlyNote extends StatelessWidget {
  const ReadOnlyNote({required this.text, required this.targets, required this.onLink, this.padding, super.key});

  final String text;
  final NoteTargets targets;
  final void Function(String destination) onLink;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final markdown = NoteMarkdownContext.of(text);
    return SingleChildScrollView(
      padding: padding,
      child: SelectionArea(
        child: MarkdownView(nodes: markdown.parse(text), context: markdown, targets: targets, onLink: onLink),
      ),
    );
  }
}

class MarkdownView extends StatefulWidget {
  const MarkdownView({
    required this.nodes,
    required this.context,
    required this.targets,
    required this.onLink,
    super.key,
  });

  final List<md.Node> nodes;
  final NoteMarkdownContext context;
  final NoteTargets targets;
  final void Function(String destination) onLink;

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  final _linkTaps = <String, TapGestureRecognizer>{};

  @override
  void dispose() {
    for (final recognizer in _linkTaps.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _linkTap(String destination) =>
      (_linkTaps[destination] ??= TapGestureRecognizer())..onTap = () => widget.onLink(destination);

  @override
  Widget build(BuildContext context) {
    final builder = _MarkdownBuilder(context, widget, _linkTap);
    final children = builder.blocks(widget.nodes);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: children);
  }
}

final _highlight = Highlight()..registerLanguages(builtinAllLanguages);

class _MarkdownBuilder {
  _MarkdownBuilder(this.context, this.view, this.linkTap)
    : theme = Theme.of(context),
      base = Theme.of(context).textTheme.bodyLarge!;

  final BuildContext context;
  final MarkdownView view;
  final TapGestureRecognizer Function(String destination) linkTap;
  final ThemeData theme;
  final TextStyle base;

  ColorScheme get colors => theme.colorScheme;

  TextStyle get _monospace => monospaced(base);

  List<Widget> blocks(List<md.Node> nodes) {
    final widgets = <Widget>[];
    final inlineRun = <md.Node>[];
    void flushInline() {
      if (inlineRun.isEmpty) return;
      widgets.add(_paragraph(List.of(inlineRun), base));
      inlineRun.clear();
    }

    for (final node in nodes) {
      if (node is md.Element && _isBlock(node.tag)) {
        flushInline();
        widgets.add(_block(node));
      } else {
        inlineRun.add(node);
      }
    }
    flushInline();
    return _spaced(widgets);
  }

  static const _blockTags = {
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "p",
    "blockquote",
    "callout",
    "pre",
    "ul",
    "ol",
    "li",
    "table",
    "hr",
    "section",
    "div",
  };

  bool _isBlock(String tag) => _blockTags.contains(tag);

  List<Widget> _spaced(List<Widget> widgets) => [
    for (var i = 0; i < widgets.length; i++) ...[if (i > 0) const SizedBox(height: 8), widgets[i]],
  ];

  Widget _block(md.Element element) => switch (element.tag) {
    "h1" => _heading(element, theme.textTheme.headlineMedium),
    "h2" => _heading(element, theme.textTheme.headlineSmall),
    "h3" => _heading(element, theme.textTheme.titleLarge),
    "h4" => _heading(element, theme.textTheme.titleMedium),
    "h5" || "h6" => _heading(element, theme.textTheme.titleSmall),
    "p" => _paragraph(element.children ?? const [], base),
    "blockquote" => _quote(element),
    "callout" => _callout(element),
    "pre" => _code(element),
    "ul" || "ol" => _list(element),
    "table" => _table(element),
    "hr" => const Divider(height: 24),
    "section" => _footnotes(element),
    _ => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks(element.children ?? const [])),
  };

  Widget _heading(md.Element element, TextStyle? style) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: _paragraph(element.children ?? const [], (style ?? base).copyWith(fontWeight: FontWeight.w600)),
  );

  Widget _paragraph(List<md.Node> nodes, TextStyle style) =>
      Text.rich(TextSpan(style: style, children: inlines(nodes, style)));

  Widget _quote(md.Element element) => Container(
    padding: const EdgeInsets.only(left: 12),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: colors.outlineVariant, width: 3)),
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(color: colors.onSurfaceVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks(element.children ?? const [])),
    ),
  );

  Widget _callout(md.Element element) {
    final type = element.attributes["type"] ?? "note";
    final (color, icon) = _calloutStyle(type);
    final title = element.attributes["title"] ?? "";
    final titleNodes = title.isEmpty
        ? <md.Node>[md.Text(type.isEmpty ? type : type[0].toUpperCase() + type.substring(1))]
        : view.context.parseInline(title);
    final titleStyle = base.copyWith(color: color, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Icon(icon, size: 18, color: color),
              ),
              Expanded(child: _paragraph(titleNodes, titleStyle)),
            ],
          ),
          if (element.children?.isNotEmpty ?? false) ...[const SizedBox(height: 6), ...blocks(element.children!)],
        ],
      ),
    );
  }

  (Color, IconData) _calloutStyle(String type) => switch (type) {
    "tip" || "hint" || "success" || "check" || "done" => (Colors.green.shade600, Icons.lightbulb_outline),
    "important" || "abstract" || "summary" || "tldr" => (Colors.purple.shade400, Icons.priority_high),
    "warning" || "attention" || "question" || "help" || "faq" => (Colors.orange.shade700, Icons.warning_amber),
    "caution" ||
    "danger" ||
    "error" ||
    "failure" ||
    "fail" ||
    "missing" ||
    "bug" => (colors.error, Icons.report_outlined),
    "quote" || "cite" || "example" => (colors.onSurfaceVariant, Icons.format_quote),
    _ => (colors.primary, Icons.info_outline),
  };

  Widget _code(md.Element element) {
    final code = element.children?.firstOrNull;
    final language = code is md.Element ? (code.attributes["class"] ?? "").replaceFirst("language-", "") : "";
    var text = (code ?? element).textContent;
    if (text.endsWith("\n")) text = text.substring(0, text.length - 1);
    final style = _monospace.copyWith(fontSize: (base.fontSize ?? 16) * 0.875, height: 1.4);
    return Container(
      decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(language, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Text.rich(_highlighted(text, language, style)),
          ),
        ],
      ),
    );
  }

  TextSpan _highlighted(String text, String language, TextStyle style) {
    if (language.isEmpty) return TextSpan(text: text, style: style);
    try {
      final renderer = TextSpanRenderer(style, theme.brightness == Brightness.dark ? githubDarkTheme : githubTheme);
      _highlight.highlight(code: text, language: language).render(renderer);
      return renderer.span ?? TextSpan(text: text, style: style);
    } on Object {
      return TextSpan(text: text, style: style);
    }
  }

  Widget _list(md.Element element) {
    final ordered = element.tag == "ol";
    var number = int.tryParse(element.attributes["start"] ?? "") ?? 1;
    final items = <Widget>[];
    for (final item in element.children ?? const <md.Node>[]) {
      if (item is! md.Element) continue;
      final children = List.of(item.children ?? const <md.Node>[]);
      final checkbox = _takeCheckbox(children);
      final Widget marker;
      if (checkbox != null) {
        marker = SizedBox(
          width: 28,
          height: (base.fontSize ?? 16) * (base.height ?? 1.4),
          child: Checkbox(
            value: checkbox.attributes["checked"] == "true",
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: null,
          ),
        );
      } else {
        marker = SizedBox(
          width: 28,
          child: Text(ordered ? "${number++}." : "•", style: base, textAlign: TextAlign.center),
        );
      }
      items.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            marker,
            const SizedBox(width: 4),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks(children)),
            ),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _spacedTight(items));
  }

  List<Widget> _spacedTight(List<Widget> widgets) => [
    for (var i = 0; i < widgets.length; i++) ...[if (i > 0) const SizedBox(height: 4), widgets[i]],
  ];

  md.Element? _takeCheckbox(List<md.Node> children) {
    if (children.isEmpty) return null;
    final first = children.first;
    if (first is md.Element && first.tag == "input") {
      children.removeAt(0);
      return first;
    }
    if (first is md.Element && first.tag == "p") {
      final inner = first.children;
      if (inner != null &&
          inner.isNotEmpty &&
          inner.first is md.Element &&
          (inner.first as md.Element).tag == "input") {
        return inner.removeAt(0) as md.Element;
      }
    }
    return null;
  }

  Widget _table(md.Element element) {
    final rows = <md.Element>[];
    for (final section in element.children ?? const <md.Node>[]) {
      if (section is md.Element) {
        rows.addAll((section.children ?? const <md.Node>[]).whereType<md.Element>());
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    final columns = rows.map((row) => row.children?.length ?? 0).fold(0, (a, b) => a > b ? a : b);
    final border = BorderSide(color: colors.outlineVariant);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(horizontalInside: border, top: border, bottom: border),
        children: [
          for (final row in rows)
            TableRow(children: [for (var column = 0; column < columns; column++) _cell(row, column)]),
        ],
      ),
    );
  }

  Widget _cell(md.Element row, int column) {
    final cells = (row.children ?? const <md.Node>[]).whereType<md.Element>().toList();
    if (column >= cells.length) return const SizedBox.shrink();
    final cell = cells[column];
    final header = cell.tag == "th";
    final style = header ? base.copyWith(fontWeight: FontWeight.w600) : base;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text.rich(
        TextSpan(style: style, children: inlines(cell.children ?? const [], style)),
        textAlign: switch (cell.attributes["align"]) {
          "center" => TextAlign.center,
          "right" => TextAlign.end,
          _ => TextAlign.start,
        },
      ),
    );
  }

  Widget _footnotes(md.Element element) {
    final items = element.children?.whereType<md.Element>().expand((list) => list.children ?? const <md.Node>[]);
    final style = theme.textTheme.bodySmall!.copyWith(color: colors.onSurfaceVariant);
    final labels = view.context.footnoteNumbers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items ?? const <md.Node>[])
          if (item is md.Element)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 28, child: Text("${labels[item.footnoteLabel?.toLowerCase()] ?? ""}", style: style)),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: style,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: blocks(_withoutBackrefs(item.children ?? const [])),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  List<md.Node> _withoutBackrefs(List<md.Node> nodes) => [
    for (final node in nodes)
      if (node is md.Element && node.attributes["class"] == "footnote-backref")
        ...[]
      else if (node is md.Element && node.children != null)
        md.Element(node.tag, _withoutBackrefs(node.children!))..attributes.addAll(node.attributes)
      else
        node,
  ];

  List<InlineSpan> inlines(List<md.Node> nodes, TextStyle style) => [for (final node in nodes) _inline(node, style)];

  InlineSpan _inline(md.Node node, TextStyle style) {
    if (node is md.Text) return TextSpan(text: node.text);
    if (node is! md.Element) return TextSpan(text: node.textContent);
    final children = node.children ?? const <md.Node>[];
    switch (node.tag) {
      case "em":
        final next = style.copyWith(fontStyle: FontStyle.italic);
        return TextSpan(style: next, children: inlines(children, next));
      case "strong":
        final next = style.copyWith(fontWeight: FontWeight.w700);
        return TextSpan(style: next, children: inlines(children, next));
      case "del":
        final next = style.copyWith(decoration: TextDecoration.lineThrough);
        return TextSpan(style: next, children: inlines(children, next));
      case "code":
        return TextSpan(
          text: node.textContent,
          style: _monospace.copyWith(
            fontSize: (style.fontSize ?? 16) * 0.9,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        );
      case "br":
        return const TextSpan(text: "\n");
      case "img":
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: NoteImage(
            destination: node.attributes["src"] ?? "",
            alt: node.attributes["alt"] ?? "",
            targets: view.targets,
            onOpen: view.onLink,
          ),
        );
      case "a":
        return _link(node, style);
      case "sup":
        final small = style.copyWith(fontSize: (style.fontSize ?? 16) * 0.7, color: colors.primary);
        return WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Text(node.textContent, style: small),
        );
      case "input":
        return const TextSpan();
      default:
        return TextSpan(style: style, children: inlines(children, style));
    }
  }

  InlineSpan _link(md.Element node, TextStyle style) {
    final destination = node.attributes["href"] ?? "";
    final linkStyle = style.copyWith(
      color: colors.primary,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary.withValues(alpha: 0.4),
    );
    final recognizer = linkTap(destination);

    final children = node.children ?? const <md.Node>[];
    return TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: NoteLinkIcon(destination: destination, targets: view.targets),
          ),
        ),
        TextSpan(
          style: linkStyle,
          recognizer: recognizer,
          children: [
            for (final child in children)
              if (child is md.Element && child.tag == "img")
                _inline(child, linkStyle)
              else
                _linkText(child, linkStyle, recognizer),
          ],
        ),
      ],
    );
  }

  InlineSpan _linkText(md.Node node, TextStyle style, GestureRecognizer recognizer) {
    final span = _inline(node, style);
    return span is TextSpan
        ? TextSpan(text: span.text, style: span.style, children: span.children, recognizer: recognizer)
        : span;
  }
}
