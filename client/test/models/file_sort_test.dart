import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_sort.dart";

FileEntry _entry(String name, {bool isDir = false, int size = 0, int day = 1}) =>
    FileEntry(path: "/$name", name: name, isDir: isDir, size: size, mtime: DateTime.utc(2026, 1, day));

void main() {
  final entries = [
    _entry("b.txt", size: 50, day: 3),
    _entry("Photos", isDir: true, size: 100, day: 1),
    _entry("a.jpg", size: 10, day: 2),
    _entry("Archive", isDir: true, size: 5, day: 4),
  ];

  List<String> names(FileSort sort) => sort.apply(entries).map((entry) => entry.name).toList();

  test("sorts folders and files separately with folders on top", () {
    expect(names(const FileSort(field: FileSortField.size, ascending: false)), ["Photos", "Archive", "b.txt", "a.jpg"]);
  });

  test("sorts everything together when folders are not pinned", () {
    expect(names(const FileSort(field: FileSortField.size, foldersFirst: false)), [
      "Archive",
      "a.jpg",
      "b.txt",
      "Photos",
    ]);
    expect(names(const FileSort(field: FileSortField.modified, foldersFirst: false)), [
      "Photos",
      "a.jpg",
      "b.txt",
      "Archive",
    ]);
  });

  test("groups folders by type when not pinned", () {
    expect(names(const FileSort(field: FileSortField.type, foldersFirst: false)), [
      "Archive",
      "Photos",
      "a.jpg",
      "b.txt",
    ]);
  });
}
