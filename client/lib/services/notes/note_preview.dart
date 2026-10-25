import "package:markdown/markdown.dart" as md;

import "package:polder/services/notes/note_markdown.dart";

class NotePreview {
  const NotePreview({this.image, this.excerpt, this.links = const []});

  static const maxExcerptLength = 400;
  static const maxLinks = 10;

  factory NotePreview.of(String source) {
    final nodes = NoteMarkdownContext.empty.parse(source);
    return NotePreview(
      image: _firstImage(nodes),
      excerpt: _firstParagraph(nodes) ?? _firstText(nodes),
      links: _webLinks(nodes),
    );
  }

  static List<String> webLinksIn(String source) => _webLinks(NoteMarkdownContext.empty.parse(source));

  final String? image;
  final String? excerpt;
  final List<String> links;

  static const _skipped = {"h1", "h2", "h3", "h4", "h5", "h6", "hr", "pre", "table"};

  static String? _firstImage(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is! md.Element) continue;
      if (node.tag == "img") return node.attributes["src"];
      if (_firstImage(node.children ?? const []) case final found?) return found;
    }
    return null;
  }

  static List<String> _webLinks(List<md.Node> nodes) {
    final found = <String>{};
    void visit(List<md.Node> nodes) {
      for (final node in nodes) {
        if (found.length >= maxLinks || node is! md.Element) continue;
        if (node.tag == "a" && _isWebLink(node.attributes["href"])) found.add(node.attributes["href"]!);
        visit(node.children ?? const []);
      }
    }

    visit(nodes);
    return found.toList();
  }

  static bool _isWebLink(String? href) {
    final uri = href == null ? null : Uri.tryParse(href);
    return uri != null && (uri.scheme == "http" || uri.scheme == "https") && uri.host.isNotEmpty;
  }

  static String? _firstParagraph(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Element && node.tag == "p") {
        if (_clean(_text(node)) case final text?) return text;
      }
    }
    return null;
  }

  static String? _firstText(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Element && _skipped.contains(node.tag)) continue;
      if (_clean(_text(node)) case final text?) return text;
    }
    return null;
  }

  static const _blocks = {"p", "li", "ul", "ol", "blockquote", "callout", "div"};

  static String _text(md.Node node) => switch (node) {
    md.Element(:final tag, :final children?) => children.map(_text).join(_blocks.contains(tag) ? " " : ""),
    md.Element() => "",
    _ => node.textContent,
  };

  static String? _clean(String text) {
    final collapsed = text.replaceAll(RegExp(r"\s+"), " ").trim();
    if (collapsed.isEmpty) return null;
    return collapsed.length <= maxExcerptLength ? collapsed : "${collapsed.substring(0, maxExcerptLength)}…";
  }
}
