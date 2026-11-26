import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";

import "package:polder/services/update/update_feed.dart";
import "package:polder/services/update/update_manifest.dart";
import "package:polder/util/build_channel.dart";

import "update_fixtures.dart";

void main() {
  late SigningKey key;

  setUp(() async => key = await SigningKey.generate());

  Future<MockClient> serving(Map<String, List<int>> files) async => MockClient(
    (request) async => files.containsKey(request.url.path)
        ? http.Response.bytes(files[request.url.path]!, 200)
        : http.Response("", 404),
  );

  Future<Map<String, List<int>>> signed(String directory, Map<String, dynamic> json) async {
    final body = utf8.encode(jsonEncode(json));
    return {"$directory/update.json": body, "$directory/update.json.sig": utf8.encode(await key.sign(body))};
  }

  const latest = "/DonutWare/Polder/releases/latest/download";
  const nightly = "/DonutWare/Polder/releases/download/nightly";

  test("reads a signed stable manifest from the latest release", () async {
    final client = await serving(await signed(latest, manifestJson(build: 42)));

    final manifest = await UpdateFeed(client, publicKey: key.publicKey).fetch(BuildChannel.stable);

    expect(manifest!.build, 42);
    expect(manifest.assets.keys, UpdateTarget.values);
    expect(
      manifest.downloadUrl(manifest.assets[UpdateTarget.macos]!).toString(),
      "https://github.com/DonutWare/Polder/releases/download/v1.0.0/Polder-macOS-1.0.0.zip",
    );
  });

  test("reads the nightly manifest from the nightly release", () async {
    final client = await serving(await signed(nightly, manifestJson(channel: "nightly", tag: "nightly")));

    final manifest = await UpdateFeed(client, publicKey: key.publicKey).fetch(BuildChannel.nightly);

    expect(manifest!.channel, BuildChannel.nightly);
  });

  test("treats a missing release as no update", () async {
    final client = await serving({});

    expect(await UpdateFeed(client, publicKey: key.publicKey).fetch(BuildChannel.nightly), isNull);
  });

  test("rejects a manifest that was changed after signing", () async {
    final files = await signed(latest, manifestJson(build: 42));
    files["$latest/update.json"] = utf8.encode(jsonEncode(manifestJson(build: 43)));

    final feed = UpdateFeed(await serving(files), publicKey: key.publicKey);

    expect(feed.fetch(BuildChannel.stable), throwsA(isA<UpdateFeedException>()));
  });

  test("rejects a manifest signed with another key", () async {
    final other = await SigningKey.generate();
    final feed = UpdateFeed(await serving(await signed(latest, manifestJson())), publicKey: other.publicKey);

    expect(feed.fetch(BuildChannel.stable), throwsA(isA<UpdateFeedException>()));
  });

  test("rejects a manifest published for the other channel", () async {
    final feed = UpdateFeed(
      await serving(await signed(latest, manifestJson(channel: "nightly"))),
      publicKey: key.publicKey,
    );

    expect(feed.fetch(BuildChannel.stable), throwsA(isA<UpdateFeedException>()));
  });

  test("only creates a feed for a raw Ed25519 public key", () async {
    final client = MockClient((_) async => http.Response("", 404));
    final pem = "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEA${key.publicKey}\n-----END PUBLIC KEY-----";
    final spki = base64Encode([...List.filled(12, 0), ...base64Decode(key.publicKey)]);

    expect(UpdateFeed.tryCreate(client, publicKey: key.publicKey), isNotNull);
    expect(UpdateFeed.tryCreate(client, publicKey: ""), isNull);
    expect(UpdateFeed.tryCreate(client, publicKey: pem), isNull);
    expect(UpdateFeed.tryCreate(client, publicKey: spki), isNull);
  });
}
