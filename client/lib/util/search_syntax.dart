import "package:flutter/widgets.dart";

import "package:polder/models/search.dart";

// Mirrors internal/search/query.go on the server, which stays the authority on what a query means. The
// client only needs enough of the syntax to colour filters while typing and to write filters for the filter builder.

const searchKeyAliases = {
  "type": SearchKey.type,
  "kind": SearchKey.type,
  "is": SearchKey.type,
  "ext": SearchKey.ext,
  "extension": SearchKey.ext,
  "in": SearchKey.folder,
  "folder": SearchKey.folder,
  "path": SearchKey.folder,
  "modified": SearchKey.modified,
  "date": SearchKey.modified,
  "mtime": SearchKey.modified,
  "size": SearchKey.size,
  "tag": SearchKey.tag,
  "tags": SearchKey.tag,
};

const _operators = ["!=", ">=", "<=", ":", "=", ">", "<"];

final _keyPattern = RegExp("^-?([A-Za-z]+)");
final _hashTag = RegExp(r"^-?#(?=[\p{L}\p{N}_\-/]*\p{L})", unicode: true);

@immutable
class SearchToken {
  const SearchToken({required this.range, required this.text, this.filterLength = 0});

  final TextRange range;
  final String text;

  // Length of the key and operator when the token is a filter, 0 otherwise.
  final int filterLength;

  bool get isFilter => filterLength > 0;
}

List<SearchToken> tokenizeSearch(String query) {
  final tokens = <SearchToken>[];
  var start = -1;
  var inQuotes = false;
  void flush(int end) {
    if (start < 0) return;
    final text = query.substring(start, end);
    tokens.add(
      SearchToken(
        range: TextRange(start: start, end: end),
        text: text,
        filterLength: _filterLength(text),
      ),
    );
    start = -1;
  }

  for (var i = 0; i < query.length; i++) {
    final char = query[i];
    if (char.trim().isEmpty && !inQuotes) {
      flush(i);
      continue;
    }
    if (char == '"') inQuotes = !inQuotes;
    if (start < 0) start = i;
  }
  flush(query.length);
  return tokens;
}

int _filterLength(String text) {
  final hashTag = _hashTag.firstMatch(text);
  if (hashTag != null) return hashTag.end;
  final match = _keyPattern.firstMatch(text);
  if (match == null || !searchKeyAliases.containsKey(match.group(1)!.toLowerCase())) return 0;
  final rest = text.substring(match.end);
  for (final operator in _operators) {
    if (rest.startsWith(operator)) return match.end + operator.length;
  }
  return 0;
}

String searchKeyText(SearchKey key) => switch (key) {
  SearchKey.type => "type",
  SearchKey.ext => "ext",
  SearchKey.folder => "in",
  SearchKey.modified => "modified",
  SearchKey.size => "size",
  SearchKey.tag => "tag",
};

String formatSearchFilter(SearchFilter filter) {
  final values = filter.values.map(_quoteIfNeeded).toList();
  final operator = switch (filter.op) {
    SearchOp.equals || SearchOp.between => "=",
    SearchOp.notEquals => "!=",
    SearchOp.greater => ">",
    SearchOp.greaterOrEqual => ">=",
    SearchOp.less => "<",
    SearchOp.lessOrEqual => "<=",
  };
  final joined = filter.op == SearchOp.between && values.length == 2 ? "${values[0]}..${values[1]}" : values.join(",");
  return "${searchKeyText(filter.key)}$operator$joined";
}

String _quoteIfNeeded(String value) => value.contains(RegExp(r'[\s,"]')) ? '"${value.replaceAll('"', "")}"' : value;

// Returns the new text and where the caret goes.
(String, int) replaceSearchRange(String query, TextRange range, String replacement) {
  final before = query.substring(0, range.start);
  var after = query.substring(range.end);
  if (replacement.isEmpty) {
    final joined = "${before.trimRight()} ${after.trimLeft()}".trim();
    return (joined, before.trimRight().length.clamp(0, joined.length));
  }
  if (after.isNotEmpty && !after.startsWith(" ")) after = " $after";
  return ("$before$replacement$after", before.length + replacement.length);
}

String appendSearchFilter(String query, String filter) {
  final trimmed = query.trimRight();
  return trimmed.isEmpty ? "$filter " : "$trimmed $filter ";
}
