import "package:freezed_annotation/freezed_annotation.dart";

part "file_space.freezed.dart";

@freezed
sealed class FileSpace with _$FileSpace {
  const FileSpace._();

  const factory FileSpace.share({required int shareId}) = ShareSpace;

  const factory FileSpace.link({required String serverUrl, required String code}) = LinkSpace;
}

@freezed
abstract class SpaceLocation with _$SpaceLocation {
  const factory SpaceLocation({required FileSpace space, required String path}) = _SpaceLocation;
}

@freezed
abstract class SpaceCapabilities with _$SpaceCapabilities {
  const factory SpaceCapabilities({
    @Default(true) bool canDownload,
    @Default(false) bool canCreate,
    @Default(false) bool canEdit,
    @Default(false) bool canDelete,
    @Default(false) bool canUpload,
  }) = _SpaceCapabilities;
}
