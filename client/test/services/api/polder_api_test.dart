import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/change.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";

import "../../support/scripted_client.dart";

Map<String, dynamic> entryJson(String path) => {
  "path": path,
  "name": path.split("/").last,
  "isDir": false,
  "size": 3,
  "mtime": "2026-09-30T12:00:00Z",
  "rev": 7,
  "hash": "abc",
  "mime": "text/plain",
  "meta": <String, dynamic>{},
  "previewState": "none",
};

class _BodyWatchingClient extends http.BaseClient {
  _BodyWatchingClient(this.bodyListened);

  final bool Function() bodyListened;
  bool? listenedBeforeSend;
  List<int>? received;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    listenedBeforeSend = bodyListened();
    received = await request.finalize().toBytes();
    return jsonResponse(200, entryJson("/big.bin"));
  }
}

void main() {
  late ScriptedClient client;
  late PolderApi api;

  void serve(ScriptedHandler handler) {
    client = ScriptedClient(handler);
    api = PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: client));
  }

  test("uploads send the length, the bytes and progress", () async {
    serve((_) async => jsonResponse(200, entryJson("/a.txt")));
    final progress = <int>[];

    final entry = await api.putContent(
      "/a.txt",
      Stream.fromIterable([
        [1, 2],
        [3],
      ]),
      length: 3,
      baseRev: 5,
      mtime: DateTime.utc(2026, 10, 1, 8),
      onProgress: (sent, total) => progress.add(sent),
    );

    final request = client.requests.single;
    expect((request.method, request.path), ("PUT", "/files/content"));
    expect(request.query, {"path": "/a.txt", "baseRev": "5", "mtime": "2026-10-01T08:00:00.000Z"});
    expect(request.headers["content-type"], "application/octet-stream");
    expect(request.contentLength, 3);
    expect(request.headers.keys, isNot(contains("x-polder-upload")));
    expect(request.bytes, [1, 2, 3]);
    expect(progress, [2, 3]);
    expect(entry.rev, 7);
  });

  test("uploads are read by the HTTP client, not buffered ahead of it", () async {
    var listened = false;
    final source = StreamController<List<int>>(onListen: () => listened = true);
    final watcher = _BodyWatchingClient(() => listened);
    api = PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: watcher));

    final upload = api.putContent("/big.bin", source.stream, length: 2);
    await Future<void>.delayed(Duration.zero);
    source.add([4, 2]);
    unawaited(source.close());
    await upload;

    expect(watcher.listenedBeforeSend, isFalse);
    expect(watcher.received, [4, 2]);
  });

  test("ranged downloads send Range and If-Match and stream the bytes", () async {
    serve((_) async => bytesResponse(206, [5, 6, 7]));

    final stream = await api.openContent("/a.txt", range: const ByteRange(10, 3), ifMatchRev: 7);

    expect(await stream.expand((chunk) => chunk).toList(), [5, 6, 7]);
    expect(client.requests.single.headers["Range"], "bytes=10-12");
    expect(client.requests.single.headers["If-Match"], "\"7\"");
  });

  test("a failed download reports the server's error", () async {
    serve(
      (_) async => jsonResponse(412, {
        "error": {"code": "precondition_failed", "message": "changed"},
      }),
    );

    await expectLater(
      api.openContent("/a.txt", ifMatchRev: 1),
      throwsA(isA<PreconditionFailedException>().having((e) => e.serverMessage, "message", "changed")),
    );
  });

  test("a missing thumbnail is null", () async {
    serve(
      (_) async => jsonResponse(404, {
        "error": {"code": "not_found", "message": ""},
      }),
    );

    expect(await api.preview("/a.jpg"), isNull);
    expect(client.requests.single.query, {"path": "/a.jpg", "size": "256"});
  });

  test("the change feed carries deletes without an entry", () async {
    serve(
      (_) async => jsonResponse(200, {
        "changes": [
          {"seq": 1, "type": "upsert", "path": "/a.txt", "entry": entryJson("/a.txt")},
          {"seq": 2, "type": "delete", "path": "/b.txt", "entry": null},
        ],
        "cursor": 2,
        "hasMore": false,
      }),
    );

    final page = await api.changes(cursor: 0);

    expect(page.changes.map((change) => (change.type, change.path, change.entry?.rev)), [
      (ChangeType.upsert, "/a.txt", 7),
      (ChangeType.delete, "/b.txt", null),
    ]);
  });

  test("an unreachable server is a network error", () async {
    serve((_) async => throw http.ClientException("connection refused"));

    await expectLater(api.me(), throwsA(isA<NetworkException>()));
  });
}
