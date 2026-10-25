import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notes/note_preview.dart";

void main() {
  test("the first image and first paragraph are picked", () {
    final preview = NotePreview.of("""
# Trip

Some *first* words
across lines.

![Beach](photos/beach.jpg)

Second paragraph.
""");
    expect(preview.image, "photos/beach.jpg");
    expect(preview.excerpt, "Some first words across lines.");
  });

  test("a paragraph holding only an image is not the excerpt", () {
    final preview = NotePreview.of("![a](a.png)\n\nText after.");
    expect(preview.image, "a.png");
    expect(preview.excerpt, "Text after.");
  });

  test("without paragraphs the first non-heading block is used", () {
    final preview = NotePreview.of("# Title\n\n- one\n- two");
    expect(preview.image, isNull);
    expect(preview.excerpt, "one two");
  });

  test("an empty note has no preview", () {
    final preview = NotePreview.of("");
    expect(preview.image, isNull);
    expect(preview.excerpt, isNull);
  });

  test("long excerpts are shortened", () {
    final preview = NotePreview.of("word " * 200);
    expect(preview.excerpt!.length, NotePreview.maxExcerptLength + 1);
    expect(preview.excerpt, endsWith("…"));
  });
}
