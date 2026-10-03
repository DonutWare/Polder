import "package:freezed_annotation/freezed_annotation.dart";

part "local_file_state.freezed.dart";
part "local_file_state.g.dart";

@freezed
abstract class LocalFileState with _$LocalFileState {
  const factory LocalFileState({
    required String relativePath,
    @Default(false) bool isDir,
    @Default(0) int size,
    required DateTime mtime,
    @Default("") String hash,
  }) = _LocalFileState;

  factory LocalFileState.fromJson(Map<String, dynamic> json) => _$LocalFileStateFromJson(json);
}
