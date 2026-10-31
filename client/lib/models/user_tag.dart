import "package:flutter/painting.dart";

import "package:freezed_annotation/freezed_annotation.dart";

part "user_tag.freezed.dart";

final tagNamePattern = RegExp(r"^[\p{L}\p{N}_\-/]{1,64}$", unicode: true);
final _letter = RegExp(r"\p{L}", unicode: true);

bool isValidTagName(String name) => tagNamePattern.hasMatch(name) && _letter.hasMatch(name);

String tagKey(String name) => name.toLowerCase();

@freezed
abstract class UserTag with _$UserTag {
  const UserTag._();

  const factory UserTag({required int id, required String name, required Color color, @Default(0) int count}) =
      _UserTag;

  String get key => tagKey(name);
}

@freezed
abstract class TagAssignmentResult with _$TagAssignmentResult {
  const TagAssignmentResult._();

  const factory TagAssignmentResult({required String path, String? error}) = _TagAssignmentResult;

  bool get failed => error != null && error!.isNotEmpty;
}
