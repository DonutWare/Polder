import "package:freezed_annotation/freezed_annotation.dart";

part "thumbnail_request.freezed.dart";

@freezed
abstract class ThumbnailRequest with _$ThumbnailRequest {
  const factory ThumbnailRequest({required String path, required int rev, @Default(256) int size}) = _ThumbnailRequest;
}
