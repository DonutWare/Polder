import "package:flutter/painting.dart";

import "package:markdown/markdown.dart" as md;

TextStyle monospaced(TextStyle base) =>
    base.copyWith(fontFamily: "monospace", fontFamilyFallback: const ["Menlo", "Consolas", "Courier"]);

const _videoExtensions = {"mp4", "m4v", "mov", "webm", "mkv", "avi", "mpeg", "mpg", "wmv", "ogv", "3gp"};

bool isVideoDestination(String destination) {
  final path = destination.split(RegExp(r"[?#]")).first.toLowerCase();
  final dot = path.lastIndexOf(".");
  return dot >= 0 && _videoExtensions.contains(path.substring(dot + 1));
}

final noteExtensions = md.ExtensionSet(
  const [
    md.FencedCodeBlockSyntax(),
    md.HeaderWithIdSyntax(),
    md.SetextHeaderWithIdSyntax(),
    md.TableSyntax(),
    md.UnorderedListWithCheckboxSyntax(),
    md.OrderedListWithCheckboxSyntax(),
    md.FootnoteDefSyntax(),
    CalloutSyntax(),
  ],
  [md.InlineHtmlSyntax(), md.StrikethroughSyntax(), md.EmojiSyntax(), md.AutolinkExtensionSyntax()],
);

class NoteMarkdownContext {
  NoteMarkdownContext._(this._linkReferences, this._footnotes, this._footnoteOrder);

  factory NoteMarkdownContext.of(String source) {
    final document = _document();
    document.parse(source);
    return NoteMarkdownContext._(Map.of(document.linkReferences), {
      for (final label in document.footnoteReferences.keys) label: 1,
    }, List.of(document.footnoteLabels));
  }

  static final empty = NoteMarkdownContext._(const {}, const {}, const []);

  final Map<String, md.LinkReference> _linkReferences;
  final Map<String, int> _footnotes;
  final List<String> _footnoteOrder;

  List<md.Node> parse(String blockSource) {
    final document = _document();
    document.linkReferences.addAll(_linkReferences);
    document.footnoteReferences.addAll(_footnotes);
    document.footnoteLabels.addAll(_footnoteOrder);
    return document.parse(blockSource);
  }

  Map<String, int> get footnoteNumbers => {for (var i = 0; i < _footnoteOrder.length; i++) _footnoteOrder[i]: i + 1};

  List<md.Node> parseInline(String text) => _document().parseInline(text);

  static md.Document _document() => md.Document(extensionSet: noteExtensions, encodeHtml: false);
}

class CalloutSyntax extends md.BlockquoteSyntax {
  const CalloutSyntax();

  static final _header = RegExp(r"^ {0,3}>[ \t]?\[!([^\]\s]+)\][+-]?[ \t]*(.*)$");

  @override
  bool canParse(md.BlockParser parser) => _header.hasMatch(parser.current.content);

  @override
  md.Node parse(md.BlockParser parser) {
    final header = _header.firstMatch(parser.current.content)!;
    parser.advance();
    final children = !parser.isDone && pattern.hasMatch(parser.current.content)
        ? md.BlockParser(parseChildLines(parser), parser.document).parseLines(parentSyntax: this)
        : <md.Node>[];
    return md.Element("callout", children)
      ..attributes["type"] = header.group(1)!.toLowerCase()
      ..attributes["title"] = header.group(2)!.trim();
  }
}
