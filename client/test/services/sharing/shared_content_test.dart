import "package:flutter_test/flutter_test.dart";

import "package:polder/services/sharing/shared_content.dart";

void main() {
  test("ignores anything without files or text", () {
    expect(SharedContent.fromMap(null), isNull);
    expect(SharedContent.fromMap({"files": <Object>[], "text": "  "}), isNull);
  });

  test("reads shared files", () {
    final content = SharedContent.fromMap({
      "files": [
        {"uri": "content://media/1", "name": "Holiday.jpg", "extension": "jpg"},
        {"uri": "content://media/2", "name": "notes", "extension": "pdf"},
        {"name": "missing-uri.txt"},
      ],
      "text": "A caption",
    })!;

    expect(content.isText, isFalse);
    expect(content.count, 2);
    expect([for (final file in content.files) file.name], ["Holiday.jpg", "notes.pdf"]);
    expect(content.files.first.uri, "content://media/1");
  });

  test("falls back to a safe name", () {
    final content = SharedContent.fromMap({
      "files": [
        {"uri": "content://a", "name": null, "extension": "png"},
        {"uri": "content://b", "name": "..", "extension": null},
        {"uri": "content://c", "name": "a/b.txt"},
      ],
    })!;

    expect([for (final file in content.files) file.name], ["Shared file.png", "Shared file", "a_b.txt"]);
  });

  test("keeps names unique within one share", () {
    final content = SharedContent.fromMap({
      "files": [
        {"uri": "content://a", "name": "image.jpg"},
        {"uri": "content://b", "name": "IMAGE.jpg"},
        {"uri": "content://c", "name": "image.jpg"},
      ],
    })!;

    expect([for (final file in content.files) file.name], ["image.jpg", "IMAGE (2).jpg", "image (3).jpg"]);
  });

  test("turns shared text into a text file", () {
    final content = SharedContent.fromMap({"text": " https://example.com ", "subject": "Read/later"})!;

    expect(content.isText, isTrue);
    expect(content.count, 1);
    expect(content.text, "https://example.com");
    expect(content.textFileName, "Read_later.txt");
    expect(SharedContent.fromMap({"text": "hello"})!.textFileName, "Shared text.txt");
  });
}
