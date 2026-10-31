import "package:flutter/widgets.dart";

import "package:flutter_test/flutter_test.dart";

import "package:polder/models/search.dart";
import "package:polder/util/fuzzy_match.dart";
import "package:polder/util/search_syntax.dart";

void main() {
  group("tokenizeSearch", () {
    test("splits on spaces outside quotes and marks tags", () {
      final tokens = tokenizeSearch('cat in="/My Photos" -type:gif size>=1mb unknown=x');

      expect(tokens.map((token) => token.text), ["cat", 'in="/My Photos"', "-type:gif", "size>=1mb", "unknown=x"]);
      expect(tokens.map((token) => token.filterLength), [0, 3, 6, 6, 0]);
      expect(tokens[1].range, const TextRange(start: 4, end: 19));
    });

    test("marks tag filters and #tags", () {
      final tokens = tokenizeSearch("tag=work #home -#later #123");
      expect(tokens.map((token) => token.filterLength), [4, 1, 2, 0]);
    });

    test("a key without an operator is plain text", () {
      expect(tokenizeSearch("type").single.isFilter, isFalse);
    });
  });

  group("formatSearchFilter", () {
    test("writes each operator", () {
      String format(SearchKey key, SearchOp op, List<String> values) =>
          formatSearchFilter(SearchFilter(key: key, op: op, values: values));

      expect(format(SearchKey.type, SearchOp.equals, ["png", "jpg"]), "type=png,jpg");
      expect(format(SearchKey.type, SearchOp.notEquals, ["gif"]), "type!=gif");
      expect(format(SearchKey.folder, SearchOp.equals, ["/My Docs"]), 'in="/My Docs"');
      expect(format(SearchKey.modified, SearchOp.greater, ["7d"]), "modified>7d");
      expect(format(SearchKey.size, SearchOp.between, ["1mb", "5mb"]), "size=1mb..5mb");
    });
  });

  group("replaceSearchRange", () {
    test("replaces a filter in place and keeps one space after it", () {
      final (text, caret) = replaceSearchRange(
        "cat type=png size>1mb",
        const TextRange(start: 4, end: 12),
        "type!=gif",
      );

      expect(text, "cat type!=gif size>1mb");
      expect(caret, 13);
    });

    test("removing a filter collapses the gap", () {
      final (text, _) = replaceSearchRange("cat type=png size>1mb", const TextRange(start: 4, end: 12), "");

      expect(text, "cat size>1mb");
    });

    test("completing a value leaves room to add another with a comma", () {
      final (text, caret) = replaceSearchRange("type=pdf,p", const TextRange(start: 9, end: 10), "png");

      expect(text, "type=pdf,png");
      expect(caret, 12);
    });

    test("completing a key leaves the caret right after the operator", () {
      final (text, caret) = replaceSearchRange("cat ty", const TextRange(start: 4, end: 6), "type=");

      expect(text, "cat type=");
      expect(caret, 9);
    });
  });

  test("appendSearchFilter adds a filter after whatever was typed", () {
    expect(appendSearchFilter("", "type=pdf"), "type=pdf ");
    expect(appendSearchFilter("report  ", "type=pdf"), "report type=pdf ");
  });

  group("fuzzyMatch", () {
    test("prefers whole substrings at word starts", () {
      final word = fuzzyMatch("trash", "Trash")!;
      final inside = fuzzyMatch("ash", "Trash")!;

      expect(word.score, greaterThan(inside.score));
      expect(word.ranges, [const TextRange(start: 0, end: 5)]);
    });

    test("matches characters in order", () {
      expect(fuzzyMatch("adus", "Admin users")!.ranges, [
        const TextRange(start: 0, end: 2),
        const TextRange(start: 6, end: 8),
      ]);
      expect(fuzzyMatch("xyz", "Settings"), isNull);
    });
  });
}
