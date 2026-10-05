import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/scan_session.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/document_scan_provider.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

final _onePixelPng = base64Decode(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
);

class _ServerWithMe extends http.BaseClient {
  _ServerWithMe(this.server);

  final FakePolderServer server;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path == "/api/v1/auth/me") return jsonResponse(200, userJson());
    return server.send(request);
  }
}

void main() {
  late Directory temp;
  late FakePolderServer server;
  late ProviderHarness harness;
  late List<String> pages;
  late ScanRequest request;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp("scan_test");
    pages = [
      for (final name in ["a.png", "b.png", "c.png"])
        (await File("${temp.path}/$name").writeAsBytes([..._onePixelPng, name.codeUnitAt(0)])).path,
    ];
    server = FakePolderServer()..putFile("/Docs/keep.txt", "k".codeUnits);
    harness = ProviderHarness(httpClient: _ServerWithMe(server), account: testAccount());
    request = ScanRequest(directory: "/Docs", pages: pages.take(2).toList());
    harness.container.listen(scanSessionProvider(request), (_, _) {});
    await harness.container.read(accountProvider.future);
  });

  tearDown(() async {
    harness.dispose();
    await temp.delete(recursive: true);
  });

  ScanSessionNotifier session() => harness.container.read(scanSessionProvider(request).notifier);
  ScanSession state() => harness.container.read(scanSessionProvider(request));

  Future<void> until(bool Function() condition) async {
    for (var i = 0; i < 200 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(condition(), isTrue);
  }

  test("starts as a dated PDF in the requested folder", () {
    expect(state().directory, "/Docs");
    expect(state().name, startsWith("Scan "));
    expect(state().format, ScanFormat.pdf);
    expect(state().fileName, "${state().name}.pdf");
    expect(state().canSave, isTrue);
  });

  test("adds, reorders and removes pages", () {
    session().addPages([pages[2]]);
    session().reorderPage(2, 0);
    expect(state().pages, [pages[2], pages[0], pages[1]]);

    session().removePage(1);
    expect(state().pages, [pages[2], pages[1]]);
  });

  test("cannot save without pages or with an invalid name", () {
    session().setName("a/b");
    expect(state().canSave, isFalse);

    session()
      ..setName("Receipt")
      ..removePage(0)
      ..removePage(0);
    expect(state().canSave, isFalse);
  });

  test("saves all pages as one PDF and removes the local scans", () async {
    session().setName("Receipt");
    await session().save();

    await until(() => server.contentOf("/Docs/Receipt.pdf") != null);
    final pdf = latin1.decode(server.contentOf("/Docs/Receipt.pdf")!);
    expect(pdf, startsWith("%PDF"));
    expect(RegExp(r"/Type\s*/Page\b").allMatches(pdf), hasLength(2));
    await until(() => !File(pages[0]).existsSync() && !File(pages[1]).existsSync());
  });

  test("saves pages as numbered images in a new folder", () async {
    session()
      ..setName("Receipt")
      ..setFormat(ScanFormat.images)
      ..reorderPage(1, 0);
    await session().save();

    await until(() => server.contentOf("/Docs/Receipt/Page 02.png") != null);
    expect(server.nodes["/Docs/Receipt"]!.isDir, isTrue);
    expect(server.contentOf("/Docs/Receipt/Page 01.png")!.last, "b".codeUnitAt(0));
    expect(server.contentOf("/Docs/Receipt/Page 02.png")!.last, "a".codeUnitAt(0));
    await until(() => !File(pages[0]).existsSync());
  });

  test("discarding the session removes the local scans", () async {
    harness.container.invalidate(scanSessionProvider(request));
    await until(() => !File(pages[0]).existsSync() && !File(pages[1]).existsSync());
    expect(File(pages[2]).existsSync(), isTrue);
  });
}
