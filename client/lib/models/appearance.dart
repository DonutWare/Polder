import "package:flutter/material.dart";

import "package:freezed_annotation/freezed_annotation.dart";

part "appearance.freezed.dart";

enum AccentPreset {
  polder(Color(0xFF24E2F2)),
  blue(Color(0xFF2B6CB0)),
  teal(Color(0xFF0F9D8A)),
  green(Color(0xFF3E9B4F)),
  violet(Color(0xFF6D4AD8)),
  rose(Color(0xFFD1456F)),
  orange(Color(0xFFE0712C)),
  slate(Color(0xFF5A6B82));

  const AccentPreset(this.color);

  final Color color;
}

@freezed
abstract class Appearance with _$Appearance {
  const Appearance._();

  static const defaultAccent = Color(0xFF24E2F2);

  const factory Appearance({@Default(ThemeMode.system) ThemeMode mode, Color? accent, Color? systemAccent}) =
      _Appearance;

  Color get seed => accent ?? systemAccent ?? defaultAccent;

  bool isAccent(Color color) => accent?.toARGB32() == color.toARGB32();
}
