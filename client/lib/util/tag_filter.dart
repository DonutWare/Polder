import "package:polder/models/user_tag.dart";
import "package:polder/util/fuzzy_match.dart";

List<UserTag> filterTags(List<UserTag> tags, String query) {
  final needle = query.trim();
  if (needle.isEmpty) return [...tags]..sort((a, b) => b.count.compareTo(a.count));
  final scored = [
    for (final tag in tags)
      if (fuzzyMatch(needle, tag.name) case final match?) (tag, match.score),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final (tag, _) in scored) tag];
}

bool offersNewTag(List<UserTag> tags, String query) =>
    isValidTagName(query) && !tags.any((tag) => tag.key == tagKey(query));
