import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/token_pair.dart";
import "package:nomad/models/user.dart";

part "account.freezed.dart";
part "account.g.dart";

@freezed
abstract class Account with _$Account {
  const Account._();

  const factory Account({
    required String serverUrl,
    required String deviceName,
    required String accessToken,
    required String refreshToken,
    required User user,
  }) = _Account;

  factory Account.fromTokens({required String serverUrl, required String deviceName, required TokenPair tokens}) =>
      Account(
        serverUrl: serverUrl,
        deviceName: deviceName,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        user: tokens.user,
      );

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  String get id => "${user.username}@$serverUrl";

  Account withTokens(TokenPair tokens) =>
      copyWith(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken, user: tokens.user);
}
