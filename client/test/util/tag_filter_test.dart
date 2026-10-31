import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/user_tag.dart";
import "package:polder/util/tag_filter.dart";

const _tags = [
  UserTag(id: 1, name: "work", color: Color(0xFFFF0000), count: 1),
  UserTag(id: 2, name: "homework", color: Color(0xFF00FF00), count: 5),
  UserTag(id: 3, name: "travel", color: Color(0xFF0000FF), count: 3),
];

void main() {
  test("an empty query lists the most used tags first", () {
    expect(filterTags(_tags, "").map((tag) => tag.name), ["homework", "travel", "work"]);
  });

  test("typing shortens the list, best match first", () {
    expect(filterTags(_tags, "work").map((tag) => tag.name), ["work", "homework"]);
    expect(filterTags(_tags, "zz"), isEmpty);
  });

  test("a new tag is offered only for a valid unknown name", () {
    expect(offersNewTag(_tags, "Work"), isFalse);
    expect(offersNewTag(_tags, "garden"), isTrue);
    expect(offersNewTag(_tags, "two words"), isFalse);
    expect(offersNewTag(_tags, "123"), isFalse);
  });

  test("tag names follow the server's rules", () {
    expect(isValidTagName("project/polder"), isTrue);
    expect(isValidTagName("café"), isTrue);
    expect(isValidTagName("a#b"), isFalse);
  });
}
