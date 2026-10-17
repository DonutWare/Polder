import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/util/remote_path.dart";

part "file_entry.freezed.dart";
part "file_entry.g.dart";

enum PreviewState { none, pending, ready, failed }

const markdownMime = "text/markdown";
const noteExtension = "md";

@freezed
abstract class FileEntry with _$FileEntry {
  const FileEntry._();

  const factory FileEntry({
    @Default(0) int id,
    required String path,
    required String name,
    @Default(false) bool isDir,
    @Default(0) int size,
    required DateTime mtime,
    @Default(0) int rev,
    @Default("") String hash,
    @Default("") String mime,
    @Default(<String, dynamic>{}) Map<String, dynamic> meta,
    @JsonKey(unknownEnumValue: PreviewState.none) @Default(PreviewState.none) PreviewState previewState,
  }) = _FileEntry;

  factory FileEntry.fromJson(Map<String, dynamic> json) => _$FileEntryFromJson(json);

  factory FileEntry.folder(String path, {required String rootName}) => FileEntry(
    path: path,
    name: path == RemotePath.root ? rootName : RemotePath.name(path),
    isDir: true,
    mtime: DateTime.now(),
  );

  bool get hasPreview => previewState == PreviewState.ready;

  bool get isImage => mime.startsWith("image/");

  bool get isVideo => mime.startsWith("video/");

  bool get isAudio => mime.startsWith("audio/");

  bool get isPdf => mime == "application/pdf";

  bool get isMarkdown => !isDir && mime == markdownMime;

  String get displayName => isMarkdown ? RemotePath.withoutExtension(name) : name;

  int? get width => _metaInt("width");

  int? get height => _metaInt("height");

  int? get pageCount => _metaInt("pages");

  DateTime? get takenAt => DateTime.tryParse(meta["takenAt"]?.toString() ?? "");

  int? _metaInt(String key) => switch (meta[key]) {
    final num value => value.toInt(),
    _ => null,
  };
}
