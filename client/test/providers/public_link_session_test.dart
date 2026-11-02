import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/browser/transfers_provider.dart";
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
        case ("POST", "/public/links/Ab3dE9xQ2k/office-sessions"):
          if (request.headers["x-polder-share-token"] != "token-1") {
            return jsonResponse(401, {
              "error": {"code": "unauthorized", "message": "unlock first"},
            });
          }
          return jsonResponse(201, {
            "editorUrl": "/office/editor?path=${(request.data! as Map)["path"]}",
            "hostPage": "/office/host.html",
            "accessToken": "wopi-token",
            "accessTokenTtl": 0,
            "readOnly": true,
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

  Future<void> unlocked() async {
    harness.container.listen(publicLinkSessionProvider(space), (_, _) {});
    await harness.container.read(publicLinkSessionProvider(space).future);
    await harness.container.read(publicLinkSessionProvider(space).notifier).unlock("hunter22");
  }

  test("in a browser a shared folder is saved by the browser as a zip", () async {
    await unlocked();
    harness.filePicker.savesInBrowser = true;

    await harness.container
        .read(transfersProvider.notifier)
        .downloadFromSpace(space, FileEntry.folder("/Trip", rootName: "Trip"));

    final url = harness.filePicker.browserSaves["Trip.zip"]!;
    expect(url.toString(), startsWith("https://files.example.com/api/v1/public/links/Ab3dE9xQ2k/archive?"));
    expect(url.queryParameters, {"path": "/Trip", "token": "token-1"});
    expect(harness.container.read(transfersProvider), isEmpty);
  });

  test("in a browser a shared file is saved by the browser", () async {
    await unlocked();
    harness.filePicker.savesInBrowser = true;
    final file = FileEntry(path: "/photo.txt", name: "photo.txt", mtime: DateTime.utc(2026));

    await harness.container.read(transfersProvider.notifier).downloadFromSpace(space, file);

    final url = harness.filePicker.browserSaves["photo.txt"]!;
    expect(url.path, "/api/v1/public/links/Ab3dE9xQ2k/content");
    expect(url.queryParameters, {"path": "/photo.txt", "token": "token-1", "download": "true"});
  });

  test("a video in a shared folder streams with the token in a header outside a browser", () async {
    await unlocked();

    final source = await harness.container.read(fileSpaceApiProvider(space)).mediaSource("/clip.mp4", inBrowser: false);

    expect(source.url.queryParameters, {"path": "/clip.mp4"});
    expect(source.headers, {"X-Polder-Share-Token": "token-1"});
  });

  test("a video in a shared folder streams with the token in its address in a browser", () async {
    await unlocked();

    final source = await harness.container.read(fileSpaceApiProvider(space)).mediaSource("/clip.mp4", inBrowser: true);

    expect(source.url.queryParameters, {"path": "/clip.mp4", "token": "token-1"});
    expect(source.headers, isEmpty);
  });

  test("a document in a shared folder opens in a read-only editor session", () async {
    await unlocked();

    final session = await harness.container
        .read(fileSpaceApiProvider(space))
        .startEditorSession("/report.docx", origin: "https://files.example.com");

    expect(session.readOnly, isTrue);
    expect(session.editorUrl, "/office/editor?path=/report.docx");
  });
}
