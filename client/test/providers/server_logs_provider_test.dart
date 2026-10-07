import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/server_log.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/admin/server_logs_provider.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late List<Map<String, dynamic>> log;
  late List<RecordedRequest> requests;
  const all = ServerLogFilter();

  Map<String, dynamic> entry(int n) => {
    "id": "polder-2026-03-01.log:${n * 100}",
    "time": DateTime.utc(2026, 3, 1, 12, 0, n).toIso8601String(),
    "level": n.isEven ? "INFO" : "WARN",
    "component": "scanner",
    "message": "line $n",
    "attrs": {"user": "alice", "count": n},
  };

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    requests.add(request);
    final limit = int.parse(request.query["limit"] ?? "100");
    final before = request.query["before"];
    final newestFirst = log.reversed.toList();
    final start = before == null ? 0 : newestFirst.indexWhere((e) => e["id"] == before) + 1;
    final page = newestFirst.skip(start).take(limit).toList();
    final more = start + limit < newestFirst.length;
    return jsonResponse(200, {"entries": page, "nextCursor": more ? page.last["id"] : ""});
  }

  setUp(() {
    log = [for (var n = 0; n < 250; n++) entry(n)];
    requests = [];
    harness = ProviderHarness(
      httpClient: ScriptedClient(handle),
      account: testAccount(role: UserRole.admin),
    );
    harness.container.listen(serverLogsProvider(all), (_, _) {});
  });

  tearDown(() => harness.dispose());

  List<String> messages() => [
    for (final e in harness.container.read(serverLogsProvider(all)).value!.entries) e.message,
  ];

  test("parses entries and pages back through older ones", () async {
    final first = await harness.container.read(serverLogsProvider(all).future);
    expect(first.entries, hasLength(100));
    expect(first.entries.first.message, "line 249");
    expect(first.entries.first.level, LogLevel.warn);
    expect(first.entries.first.attrs, {"user": "alice", "count": "249"});

    await harness.container.read(serverLogsProvider(all).notifier).loadMore();
    await harness.container.read(serverLogsProvider(all).notifier).loadMore();
    expect(messages(), hasLength(250));
    expect(messages().last, "line 0");
    expect(harness.container.read(serverLogsProvider(all)).value!.hasMore, isFalse);
  });

  test("the filter is sent with the query", () async {
    const filter = ServerLogFilter(minLevel: LogLevel.warn, component: "search", query: "alice");
    harness.container.listen(serverLogsProvider(filter), (_, _) {});
    await harness.container.read(serverLogsProvider(filter).future);

    expect(requests.last.query, containsPair("level", "warn"));
    expect(requests.last.query, containsPair("component", "search"));
    expect(requests.last.query, containsPair("q", "alice"));
    expect(requests.last.query.containsKey("before"), isFalse);
  });

  test("fetching newer entries puts only the new ones on top", () async {
    await harness.container.read(serverLogsProvider(all).future);
    await harness.container.read(serverLogsProvider(all).notifier).loadMore();
    log.addAll([entry(250), entry(251)]);

    await harness.container.read(serverLogsProvider(all).notifier).fetchNewer();

    expect(messages().take(3), ["line 251", "line 250", "line 249"]);
    expect(messages(), hasLength(202));
  });

  test("a burst bigger than a page replaces the list instead of leaving a gap", () async {
    await harness.container.read(serverLogsProvider(all).future);
    log.addAll([for (var n = 250; n < 400; n++) entry(n)]);

    await harness.container.read(serverLogsProvider(all).notifier).fetchNewer();

    expect(messages().first, "line 399");
    expect(messages(), hasLength(100));
  });
}
