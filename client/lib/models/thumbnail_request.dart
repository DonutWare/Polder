import "package:freezed_annotation/freezed_annotation.dart";

part "thumbnail_request.freezed.dart";

@freezed
sealed class ThumbnailRequest with _$ThumbnailRequest {
  const factory ThumbnailRequest.file({required String path, required int rev, @Default(256) int size}) =
      FileThumbnailRequest;

  const factory ThumbnailRequest.trash({required int itemId, @Default(256) int size}) = TrashThumbnailRequest;
}
