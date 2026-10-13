import "package:flutter_test/flutter_test.dart";

import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../../support/provider_harness.dart";

void main() {
  group("PreferencesCredentialsStore", () {
    test("loads null when nothing is stored", () async {
      expect(await PreferencesCredentialsStore(InMemoryPreferencesStore()).load(), isNull);
    });

    test("round-trips a saved account", () async {
      final store = PreferencesCredentialsStore(InMemoryPreferencesStore());
      final account = testAccount();

      await store.save(account);

      expect(await store.load(), account);
    });

    test("clear removes the account", () async {
      final store = PreferencesCredentialsStore(InMemoryPreferencesStore());
      await store.save(testAccount());

      await store.clear();

      expect(await store.load(), isNull);
    });
  });
}
