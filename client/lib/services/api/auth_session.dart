import "package:polder/models/token_pair.dart";

abstract interface class AuthSession {
  String? get accessToken;

  Future<String?> readRefreshToken();

  Future<void> storeTokens(TokenPair tokens);

  Future<void> expire();
}
