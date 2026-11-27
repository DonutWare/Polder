import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/file_entry.dart";

FileEntry _file(String name, {String mime = "application/octet-stream", bool isDir = false}) =>
    FileEntry(path: "/$name", name: name, mime: mime, isDir: isDir, mtime: DateTime.utc(2026));

void main() {
  test("text is recognised by mime type or by name", () {
    expect(_file("notes.md", mime: markdownMime).isText, isTrue);
    expect(_file("notes.md", mime: markdownMime).isPlainText, isFalse);
    expect(_file("todo.txt", mime: "text/plain").isPlainText, isTrue);
    expect(_file("server.log").isPlainText, isTrue);
    expect(_file("config.yaml").isText, isTrue);
    expect(_file("data", mime: "application/json").isText, isTrue);
    expect(_file(".gitignore").isText, isTrue);
    expect(_file("Makefile").isText, isTrue);
  });

  test("binary files and folders are not text", () {
    expect(_file("photo.jpg", mime: "image/jpeg").isText, isFalse);
    expect(_file("report.pdf", mime: "application/pdf").isText, isFalse);
    expect(_file("archive.zip").isText, isFalse);
    expect(_file("Docs.txt", isDir: true).isText, isFalse);
  });
}
