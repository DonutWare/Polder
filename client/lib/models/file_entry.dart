import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_mount.dart";
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
    FileMount? mount,
    @Default(false) bool sharedByYou,
    @Default(<int>[]) List<int> tagIds,
    @Default(<String>[]) List<String> otherTags,
  }) = _FileEntry;

  factory FileEntry.fromJson(Map<String, dynamic> json) => _$FileEntryFromJson(json);

  factory FileEntry.folder(String path, {required String rootName}) => FileEntry(
    path: path,
    name: path == RemotePath.root ? rootName : RemotePath.name(path),
    isDir: true,
    mtime: DateTime.now(),
  );

  bool get hasPreview => previewState == PreviewState.ready;

  bool get isMountRoot => mount?.path == path;

  bool get isImage => mime.startsWith("image/");

  bool get isVideo => mime.startsWith("video/");

  bool get isViewableMedia => !isDir && (isImage || isVideo);

  bool get isAudio => mime.startsWith("audio/");

  bool get isPdf => mime == "application/pdf";

  bool get isMarkdown => !isDir && mime == markdownMime;

  String get displayName => isMarkdown ? RemotePath.withoutExtension(name) : name;

  int? get width => _metaInt("width");

  int? get height => _metaInt("height");

  int? get pageCount => _metaInt("pages");

  DateTime? get takenAt => DateTime.tryParse(meta["takenAt"]?.toString() ?? "");

  Duration? get duration => switch (meta["duration"]) {
    final num seconds => Duration(milliseconds: (seconds * 1000).round()),
    _ => null,
  };

  String? get cameraMake => _metaString("cameraMake");

  String? get cameraModel => _metaString("cameraModel");

  String? get lens => _metaString("lens");

  double? get focalLength => _metaDouble("focalLength");

  double? get aperture => _metaDouble("aperture");

  double? get exposureTime => _metaDouble("exposureTime");

  int? get iso => _metaInt("iso");

  ({double latitude, double longitude})? get location => switch ((meta["latitude"], meta["longitude"])) {
    (final num latitude, final num longitude) => (latitude: latitude.toDouble(), longitude: longitude.toDouble()),
    _ => null,
  };

  String? get videoCodec => _metaString("videoCodec");

  String? get audioCodec => _metaString("audioCodec");

  double? get frameRate => _metaDouble("frameRate");

  int? get bitrate => _metaInt("bitrate");

  int? _metaInt(String key) => switch (meta[key]) {
    final num value => value.toInt(),
    _ => null,
  };

  double? _metaDouble(String key) => switch (meta[key]) {
    final num value => value.toDouble(),
    _ => null,
  };

  String? _metaString(String key) => switch (meta[key]) {
    final String value when value.isNotEmpty => value,
    _ => null,
  };
}
