import "package:freezed_annotation/freezed_annotation.dart";

part "link_preview.freezed.dart";

enum LinkPreviewImageKind { image, icon }

@freezed
abstract class LinkPreview with _$LinkPreview {
  const factory LinkPreview({
    required String url,
    required String siteName,
    String? title,
    String? description,
    @Default(false) bool hasImage,
    @Default(false) bool hasIcon,
  }) = _LinkPreview;
}
