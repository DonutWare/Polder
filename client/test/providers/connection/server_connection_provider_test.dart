import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/server_connection.dart";
import "package:polder/providers/connection/server_connection_provider.dart";

import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late Map<String, dynamic>? health;
  late int healthChecks;

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    if (request.path.endsWith("/healthz")) {
      healthChecks++;
      final body = health;
      if (body == null) throw http.ClientException("connection refused");
      return jsonResponse(200, body);
    }
    return jsonResponse(404, {});
  }

  ProviderHarness start() {
    healthChecks = 0;
    final created = ProviderHarness(
      httpClient: ScriptedClient(handle),
      account: testAccount(),
      monitorConnection: true,
    );
    created.container.listen(serverConnectionProvider, (_, _) {});
    return created;
  }

  ServerConnection connection() => harness.container.read(serverConnectionProvider);

  test("a healthy server is online and reports its storage", () {
    fakeAsync((async) {
      health = {"status": "ok", "storage": "full"};
      harness = start();
      async.elapse(const Duration(milliseconds: 10));

      expect(connection().isOnline, isTrue);
      expect(connection().storage, ServerStorage.full);
      harness.dispose();
    });
  });

  test("an unreachable server goes offline and comes back once it answers", () {
    fakeAsync((async) {
      health = null;
      harness = start();
      async.elapse(const Duration(milliseconds: 10));
      expect(connection().reachability, ServerReachability.offline);
      expect(connection().cause, OfflineCause.serverUnreachable);

      health = {"status": "ok"};
      async.elapse(ServerConnectionNotifier.firstRetryDelay);
      expect(connection().isOnline, isTrue);
      expect(connection().storage, ServerStorage.unknown);
      harness.dispose();
    });
  });

  test("losing the network goes offline at once without asking the server", () {
    fakeAsync((async) {
      health = {"status": "ok", "storage": "ok"};
      harness = start();
      async.elapse(const Duration(milliseconds: 10));
      final checksBefore = healthChecks;

      harness.conditions.setNetwork(false);
      async.elapse(const Duration(milliseconds: 10));
      expect(connection().cause, OfflineCause.noNetwork);
      async.elapse(const Duration(minutes: 5));
      expect(healthChecks, checksBefore);

      harness.conditions.setNetwork(true);
      async.elapse(const Duration(milliseconds: 10));
      expect(connection().isOnline, isTrue);
      harness.dispose();
    });
  });

  test("a failed request triggers a check instead of waiting for the next poll", () {
    fakeAsync((async) {
      health = {"status": "ok", "storage": "ok"};
      harness = start();
      async.elapse(const Duration(milliseconds: 10));

      health = null;
      harness.container.read(serverConnectionProvider.notifier).report(reachable: false);
      async.elapse(const Duration(milliseconds: 10));
      expect(connection().isOffline, isTrue);
      harness.dispose();
    });
  });

  test("retries back off up to the maximum delay", () {
    fakeAsync((async) {
      health = null;
      harness = start();
      async.elapse(const Duration(milliseconds: 10));
      async.elapse(const Duration(minutes: 10));
      final checks = healthChecks;
      async.elapse(ServerConnectionNotifier.maxRetryDelay * 4);
      expect(healthChecks - checks, inInclusiveRange(3, 5));
      harness.dispose();
    });
  });
}
