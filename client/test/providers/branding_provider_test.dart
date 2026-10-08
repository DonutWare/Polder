import "dart:ui";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  const server = "https://cloud.test";
  late Map<String, Object?> branding;
  late ScriptedClient client;
  late InMemoryPreferencesStore preferences;

  Future<http.StreamedResponse> handle(RecordedRequest request) async => switch (request.path) {
    "/branding" => jsonResponse(200, branding),
    _ => jsonResponse(404, {
      "error": {"code": "not_found", "message": ""},
    }),
  };

  setUp(() {
    branding = {
      "name": "Family files",
      "message": "Hello",
      "accentColor": "#12AB34",
      "icon": {"id": "a1", "contentType": "image/gif"},
      "backgrounds": [
        {"id": "b1", "contentType": "image/svg+xml"},
      ],
    };
    client = ScriptedClient(handle);
    preferences = InMemoryPreferencesStore();
  });

  ProviderHarness harness() {
    final harness = ProviderHarness(httpClient: client, preferences: preferences);
    addTearDown(harness.dispose);
    return harness;
  }

  test("loads what the server says, falling back to the app's own for empty fields", () async {
    final container = harness().container;
    await container.read(brandingProvider.notifier).load(server);

    final loaded = container.read(brandingProvider);
    expect(loaded.nameOr("Polder"), "Family files");
    expect(loaded.accent, const Color(0xFF12AB34));
    expect(loaded.iconUrl, "$server/api/v1/branding/icon/a1");
    expect(loaded.backgroundUrl(loaded.backgrounds.single), "$server/api/v1/branding/backgrounds/b1");
    expect(loaded.backgrounds.single.isSvg, isTrue);

    branding
      ..["name"] = ""
      ..remove("icon");
    await container.read(brandingProvider.notifier).load(server);
    expect(container.read(brandingProvider).nameOr("Polder"), "Polder");
    expect(container.read(brandingProvider).iconUrl, isNull);
  });

  test("the last branding is remembered for when the server can't be reached", () async {
    await harness().container.read(brandingProvider.notifier).load(server);

    client = ScriptedClient((_) async => throw http.ClientException("offline"));
    final container = harness().container;
    await container.read(brandingProvider.notifier).load(server);

    expect(container.read(brandingProvider).name, "Family files");
    expect(container.read(brandingProvider).iconUrl, "$server/api/v1/branding/icon/a1");
    expect(container.read(brandingProvider).backgrounds.single.isSvg, isTrue);

    await container.read(brandingProvider.notifier).load("https://other.test");
    expect(container.read(brandingProvider).name, isEmpty);
  });
}
