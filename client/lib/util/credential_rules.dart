import "dart:convert";

abstract final class CredentialRules {
  static const minPasswordLength = 8;

  static final _usernamePattern = RegExp(r"^[a-z0-9][a-z0-9_.-]{1,31}$");

  static bool isValidUsername(String username) => _usernamePattern.hasMatch(username.trim());

  static bool isValidPassword(String password) => utf8.encode(password).length >= minPasswordLength;
}
