import "package:flutter/widgets.dart";

@immutable
class FuzzyMatch {
  const FuzzyMatch(this.score, this.ranges);

  final double score;
  final List<TextRange> ranges;
}

// Same idea as the server's name matcher, for the few things matched on the device: whole substrings
// score best, then the query's characters in order, with a bonus for each that starts a word.
FuzzyMatch? fuzzyMatch(String query, String target) {
  final needle = query.toLowerCase().trim();
  final haystack = target.toLowerCase();
  if (needle.isEmpty) return null;

  final index = haystack.indexOf(needle);
  if (index >= 0) {
    final atWord = index == 0 || !_isWordChar(haystack[index - 1]);
    return FuzzyMatch(100 + needle.length * 10 + (atWord ? 30 : 0) + (index == 0 ? 20 : 0), [
      TextRange(start: index, end: index + needle.length),
    ]);
  }

  final ranges = <TextRange>[];
  var score = 0.0;
  var next = 0;
  for (var i = 0; i < haystack.length && next < needle.length; i++) {
    if (haystack[i] != needle[next]) continue;
    final atWord = i == 0 || !_isWordChar(haystack[i - 1]);
    score += 6 + (atWord ? 12 : 0);
    if (ranges.isNotEmpty && ranges.last.end == i) {
      score += 8;
      ranges[ranges.length - 1] = TextRange(start: ranges.last.start, end: i + 1);
    } else {
      ranges.add(TextRange(start: i, end: i + 1));
    }
    next++;
  }
  return next == needle.length && needle.length > 1 ? FuzzyMatch(score, ranges) : null;
}

bool _isWordChar(String char) => RegExp(r"[\p{L}\p{N}]", unicode: true).hasMatch(char);
