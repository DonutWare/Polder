import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/user.dart";

part "token_pair.freezed.dart";
part "token_pair.g.dart";

@freezed
abstract class TokenPair with _$TokenPair {
  const factory TokenPair({
    required String accessToken,
    required String refreshToken,
    @Default(900) int expiresIn,
    required User user,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) => _$TokenPairFromJson(json);
}
