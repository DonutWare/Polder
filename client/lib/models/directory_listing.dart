import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";

part "directory_listing.freezed.dart";
part "directory_listing.g.dart";

@freezed
abstract class DirectoryListing with _$DirectoryListing {
  const DirectoryListing._();

  const factory DirectoryListing({required String path, @Default(<FileEntry>[]) List<FileEntry> entries}) =
      _DirectoryListing;

  factory DirectoryListing.fromJson(Map<String, dynamic> json) => _$DirectoryListingFromJson(json);

  List<FileEntry> get sortedEntries => [...entries]..sort(_directoriesFirstByName);

  List<FileEntry> get directories => sortedEntries.where((entry) => entry.isDir).toList();

  static int _directoriesFirstByName(FileEntry a, FileEntry b) {
    if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
