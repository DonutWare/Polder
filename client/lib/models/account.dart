import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/token_pair.dart";
import "package:polder/models/user.dart";

part "account.freezed.dart";
part "account.g.dart";

@freezed
abstract class Account with _$Account {
  const Account._();

  const factory Account({
    required String serverUrl,
    required String accessToken,
    required String refreshToken,
    required User user,
  }) = _Account;

  factory Account.fromTokens({required String serverUrl, required TokenPair tokens}) => Account(
    serverUrl: serverUrl,
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: tokens.user,
  );

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  String get id => "${user.username}@$serverUrl";

  String get handle {
    final authority = Uri.tryParse(serverUrl)?.authority ?? "";
    return "${user.username}@${authority.isEmpty ? serverUrl : authority}";
  }

  Account withTokens(TokenPair tokens) =>
      copyWith(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken, user: tokens.user);
}
