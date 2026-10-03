import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/services/api/api_exceptions.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

class _ServerWithMe extends http.BaseClient {
  _ServerWithMe(this.server);

  final FakeNomadServer server;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path == "/api/v1/auth/me") return jsonResponse(200, userJson());
    return server.send(request);
  }
}

void main() {
  late FakeNomadServer server;
  late ProviderHarness harness;
  final account = testAccount();

  setUp(() {
    server = FakeNomadServer()
      ..putFile("/b.txt", "b".codeUnits)
      ..putFile("/Photos/p.jpg", "p".codeUnits);
    harness = ProviderHarness(httpClient: _ServerWithMe(server), account: account);
    harness.container.listen(directoryProvider("/"), (_, _) {});
  });

  tearDown(() => harness.dispose());

  DirectoryNotifier root() => harness.container.read(directoryProvider("/").notifier);

  Future<List<String>> names() async =>
      (await harness.container.read(directoryProvider("/").future)).sortedEntries.map((entry) => entry.name).toList();

  test("lists directories first, then files by name", () async {
    expect(await names(), ["Photos", "b.txt"]);
  });

  test("creating, renaming and deleting refresh the listing", () async {
    await harness.container.read(directoryProvider("/").future);

    await root().createFolder("Music");
    expect(await names(), ["Music", "Photos", "b.txt"]);

    final file = (await harness.container.read(directoryProvider("/").future)).entries
        .firstWhere((e) => e.name == "b.txt");
    await root().rename(file, "c.txt");
    expect(await names(), ["Music", "Photos", "c.txt"]);

    final renamed = (await harness.container.read(directoryProvider("/").future)).entries
        .firstWhere((e) => e.name == "c.txt");
    await root().delete(renamed);
    expect(await names(), ["Music", "Photos"]);
  });

  test("moving into a folder removes it here", () async {
    final listing = await harness.container.read(directoryProvider("/").future);
    final file = listing.entries.firstWhere((entry) => entry.name == "b.txt");

    await root().moveTo(file, "/Photos");

    expect(await names(), ["Photos"]);
    expect(server.contentOf("/Photos/b.txt"), isNotNull);
  });

  test("a stale rev surfaces a conflict", () async {
    final listing = await harness.container.read(directoryProvider("/").future);
    final file = listing.entries.firstWhere((entry) => entry.name == "b.txt");
    server.putFile("/b.txt", "changed".codeUnits);

    await expectLater(root().delete(file), throwsA(isA<ConflictException>()));
  });
}
