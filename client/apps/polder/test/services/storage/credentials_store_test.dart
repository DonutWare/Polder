import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_account_link/shared_account.dart";
import "package:polder_account_link/shared_account_platform.dart";
import "package:polder_core/services/storage/credentials_store.dart";
import "package:polder_core/services/storage/preferences_store.dart";

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

  group("SharedAccountCredentialsStore", () {
    late FakeSharedAccountPlatform platform;
    late InMemoryCredentialsStore appStore;
    late SharedAccountCredentialsStore store;

    setUp(() {
      platform = FakeSharedAccountPlatform();
      SharedAccountPlatform.instance = platform;
      appStore = InMemoryCredentialsStore();
      store = SharedAccountCredentialsStore(const SharedAccount("test"), appStore);
    });

    test("round-trips through the shared account", () async {
      final account = testAccount();

      await store.save(account);

      expect(await store.load(), account);
      expect(await appStore.load(), isNull);
    });

    test("moves an app-only sign-in into the shared account", () async {
      final account = testAccount();
      await appStore.save(account);

      expect(await store.load(), account);
      expect(platform.stored, isNotNull);
      expect(await appStore.load(), isNull);
    });

    test("prefers the shared account and hands back the app's own session to revoke", () async {
      final shared = testAccount();
      final own = shared.copyWith(refreshToken: "own-refresh");
      await store.save(shared);
      await appStore.save(own);

      expect(await store.load(), shared);
      expect(await store.takeSuperseded(), own);
      expect(await appStore.load(), isNull);
    });

    test("does not revoke when the app session is the shared one", () async {
      final account = testAccount();
      await store.save(account);
      await appStore.save(account);

      expect(await store.takeSuperseded(), isNull);
    });

    test("clear signs every app out", () async {
      await store.save(testAccount());

      await store.clear();

      expect(platform.stored, isNull);
      expect(await store.load(), isNull);
    });

    test("falls back to the app store when the shared account is unavailable", () async {
      platform.failing = true;
      final account = testAccount();

      await store.save(account);

      expect(await appStore.load(), account);
      expect(await store.load(), account);
    });
  });
}

class FakeSharedAccountPlatform extends SharedAccountPlatform {
  String? stored;
  bool failing = false;

  void _guard() {
    if (failing) throw PlatformException(code: "failed");
  }

  @override
  Future<String?> read(String namespace) async {
    _guard();
    return stored;
  }

  @override
  Future<void> write(String namespace, {required String name, required String json}) async {
    _guard();
    stored = json;
  }

  @override
  Future<void> remove(String namespace) async {
    _guard();
    stored = null;
  }

  @override
  Stream<void> changes(String namespace) => const Stream.empty();
}
