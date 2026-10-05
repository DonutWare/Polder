import "package:polder/models/file_entry.dart";

enum FileSortField { name, modified, size, type }

class FileSort {
  const FileSort({this.field = FileSortField.name, this.ascending = true, this.foldersFirst = true});

  final FileSortField field;
  final bool ascending;
  final bool foldersFirst;

  FileSort copyWith({FileSortField? field, bool? ascending, bool? foldersFirst}) => FileSort(
    field: field ?? this.field,
    ascending: ascending ?? this.ascending,
    foldersFirst: foldersFirst ?? this.foldersFirst,
  );

  List<FileEntry> apply(List<FileEntry> entries) => [...entries]..sort(_compare);

  int _compare(FileEntry a, FileEntry b) {
    if (foldersFirst && a.isDir != b.isDir) return a.isDir ? -1 : 1;
    final byField = switch (field) {
      FileSortField.name => 0,
      FileSortField.modified => a.mtime.compareTo(b.mtime),
      FileSortField.size => a.size.compareTo(b.size),
      FileSortField.type => _typeKey(a).compareTo(_typeKey(b)),
    };
    final result = byField != 0 ? byField : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return ascending ? result : -result;
  }

  // Folders sort as their own type so they stay grouped even when not pinned on top.
  static String _typeKey(FileEntry entry) {
    if (entry.isDir) return "";
    final dot = entry.name.lastIndexOf(".");
    return dot <= 0 ? "." : ".${entry.name.substring(dot + 1).toLowerCase()}";
  }

  @override
  bool operator ==(Object other) =>
      other is FileSort && other.field == field && other.ascending == ascending && other.foldersFirst == foldersFirst;

  @override
  int get hashCode => Object.hash(field, ascending, foldersFirst);
}
