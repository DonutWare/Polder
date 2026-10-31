import "dart:convert";
import "dart:io";

import "package:crypto/crypto.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:path/path.dart" as p;

import "package:polder/services/update/update_downloader.dart";
import "package:polder/services/update/update_manifest.dart";

import "update_fixtures.dart";

void main() {
  late Directory root;
  final payload = utf8.encode("new polder build");

  setUp(() async {
    root = await Directory.systemTemp.createTemp("polder-update-test");
    addTearDown(() => root.delete(recursive: true));
  });

  UpdateAsset asset({String? sha256Hex, int? size}) => UpdateAsset(
    name: "Polder.zip",
    sha256: sha256Hex ?? sha256.convert(payload).toString(),
    size: size ?? payload.length,
  );

  UpdateDownloader downloader(List<int> served, {List<Uri>? requests}) => UpdateDownloader(
    MockClient((request) async {
      requests?.add(request.url);
      return http.Response.bytes(served, 200);
    }),
    () async => root,
  );

  test("downloads, verifies and keeps the asset for its build", () async {
    final progress = <double>[];
    final requests = <Uri>[];

    final file = await downloader(
      payload,
      requests: requests,
    ).download(manifest(build: 7), asset(), onProgress: progress.add);

    expect(await file.readAsBytes(), payload);
    expect(p.dirname(file.path), p.join(root.path, "7"));
    expect(progress.last, 1);
    expect(requests.single.path, "/DonutWare/Polder/releases/download/v1.0.0/Polder.zip");
  });

  test("reuses an asset that was already downloaded", () async {
    await downloader(payload).download(manifest(build: 7), asset(), onProgress: (_) {});
    final requests = <Uri>[];

    await downloader(payload, requests: requests).download(manifest(build: 7), asset(), onProgress: (_) {});

    expect(requests, isEmpty);
  });

  test("rejects a download whose checksum does not match", () async {
    final download = downloader(utf8.encode("tampered build!!"))
        .download(manifest(build: 7), asset(), onProgress: (_) {});

    await expectLater(download, throwsA(isA<UpdateDownloadException>()));
    expect(await Directory(p.join(root.path, "7")).list().toList(), isEmpty);
  });

  test("removes downloads of older builds", () async {
    await downloader(payload).download(manifest(build: 7), asset(), onProgress: (_) {});

    await downloader(payload).download(manifest(build: 8), asset(), onProgress: (_) {});

    expect(await Directory(p.join(root.path, "7")).exists(), isFalse);
  });
}
