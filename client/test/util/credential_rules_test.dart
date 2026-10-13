import "package:flutter_test/flutter_test.dart";

import "package:polder/util/credential_rules.dart";

void main() {
  test("usernames follow the server's pattern", () {
    expect(CredentialRules.isValidUsername("alice"), isTrue);
    expect(CredentialRules.isValidUsername("a.b_c-1"), isTrue);
    expect(CredentialRules.isValidUsername("a"), isFalse);
    expect(CredentialRules.isValidUsername("Alice"), isFalse);
    expect(CredentialRules.isValidUsername(".alice"), isFalse);
    expect(CredentialRules.isValidUsername("a" * 33), isFalse);
  });

  test("passwords need at least eight bytes", () {
    expect(CredentialRules.isValidPassword("1234567"), isFalse);
    expect(CredentialRules.isValidPassword("12345678"), isTrue);
    expect(CredentialRules.isValidPassword("éééé"), isTrue);
  });
}
