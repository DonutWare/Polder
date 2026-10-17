import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/providers/sharing/public_link_session_provider.dart";
import "package:polder/services/api/api_exceptions.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

Map<String, Object?> entryJson(String path, {bool isDir = false}) => {
  "id": 7,
  "path": path,
  "name": path == "/" ? "Trip" : path.substring(1),
  "isDir": isDir,
  "size": 4,
  "mtime": "2026-10-01T10:00:00Z",
  "rev": 1,
  "hash": "",
  "mime": isDir ? "inode/directory" : "text/plain",
  "meta": <String, Object?>{},
  "previewState": "none",
};

void main() {
  const space = LinkSpace(serverUrl: "https://files.example.com", code: "Ab3dE9xQ2k");
  late ScriptedClient client;
  late ProviderHarness harness;

  setUp(() {
    client = ScriptedClient((request) async {
      switch ((request.method, request.path)) {
        case ("GET", "/public/links/Ab3dE9xQ2k"):
          return jsonResponse(200, {
            "needsPassword": true,
            "permissions": {"view": true, "download": true, "upload": true},
          });
        case ("POST", "/public/links/Ab3dE9xQ2k/unlock"):
          if ((request.data! as Map)["password"] != "hunter22") {
            return jsonResponse(401, {
              "error": {"code": "unauthorized", "message": "wrong password"},
            });
          }
          return jsonResponse(200, {
            "token": "token-1",
            "expiresAt": DateTime.now().add(const Duration(hours: 2)).toUtc().toIso8601String(),
            "info": {
              "needsPassword": true,
              "permissions": {"view": true, "download": true, "upload": true},
              "name": "Trip",
              "isDir": true,
            },
            "root": entryJson("/", isDir: true),
          });
        case ("GET", "/public/links/Ab3dE9xQ2k/list"):
          if (request.headers["x-polder-share-token"] != "token-1") {
            return jsonResponse(401, {
              "error": {"code": "unauthorized", "message": "unlock first"},
            });
          }
          return jsonResponse(200, {
            "path": "/",
            "entries": [entryJson("/photo.txt")],
            "indexing": false,
          });
      }
      return jsonResponse(404, {
        "error": {"code": "not_found", "message": "nope"},
      });
    });
    harness = ProviderHarness(httpClient: client);
  });

  tearDown(() => harness.dispose());

  test("a locked link shows nothing until the password is right", () async {
    final session = await harness.container.read(publicLinkSessionProvider(space).future);
    expect(session.isUnlocked, isFalse);
    expect(session.shownInfo.name, isNull);

    final notifier = harness.container.read(publicLinkSessionProvider(space).notifier);
    await expectLater(notifier.unlock("wrong"), throwsA(isA<UnauthorizedException>()));
    await notifier.unlock("hunter22");

    final unlocked = harness.container.read(publicLinkSessionProvider(space)).requireValue;
    expect(unlocked.shownInfo.name, "Trip");
    expect(unlocked.shownInfo.permissions, const LinkPermissions(upload: true));
  });

  test("an unlocked link lists its folder with the token", () async {
    harness.container.listen(publicLinkSessionProvider(space), (_, _) {});
    await harness.container.read(publicLinkSessionProvider(space).future);
    await harness.container.read(publicLinkSessionProvider(space).notifier).unlock("hunter22");

    const location = SpaceLocation(space: space, path: "/");
    final listing = await harness.container.read(spaceDirectoryProvider(location).future);
    expect(listing.entries.single.path, "/photo.txt");
    expect(harness.container.read(spaceCapabilitiesProvider(space)).canUpload, isTrue);
  });
}
