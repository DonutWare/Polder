import "dart:ui";

import "package:freezed_annotation/freezed_annotation.dart";

part "branding.freezed.dart";
part "branding.g.dart";

@freezed
abstract class ServerImage with _$ServerImage {
  const ServerImage._();

  const factory ServerImage({required String id, required String contentType}) = _ServerImage;

  factory ServerImage.fromJson(Map<String, dynamic> json) => _$ServerImageFromJson(json);

  bool get isSvg => contentType == "image/svg+xml";
}

@freezed
abstract class Branding with _$Branding {
  const Branding._();

  const factory Branding({
    String? serverUrl,
    @Default("") String name,
    @Default("") String message,
    @ColorConverter() Color? accent,
    ServerImage? icon,
    @Default(<ServerImage>[]) List<ServerImage> backgrounds,
  }) = _Branding;

  factory Branding.fromJson(Map<String, dynamic> json) => _$BrandingFromJson(json);

  String nameOr(String fallback) => name.isEmpty ? fallback : name;

  String? get iconUrl => icon == null || serverUrl == null ? null : "$serverUrl/api/v1/branding/icon/${icon!.id}";

  String backgroundUrl(ServerImage background) => "$serverUrl/api/v1/branding/backgrounds/${background.id}";
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.toARGB32();
}

Color? parseHexColor(String value) {
  if (!RegExp(r"^#[0-9A-Fa-f]{6}$").hasMatch(value)) return null;
  return Color(0xFF000000 | int.parse(value.substring(1), radix: 16));
}

String hexColor(Color color) => "#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, "0").toUpperCase()}";
