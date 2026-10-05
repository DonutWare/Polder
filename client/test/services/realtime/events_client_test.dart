import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/activity.dart";
import "package:polder/models/server_event.dart";
import "package:polder/services/realtime/events_client.dart";

import "../../support/fake_web_socket.dart";

void main() {
  test("the endpoint follows the server's scheme and path", () {
    expect(EventsClient.endpointFor("https://cloud.test").toString(), "wss://cloud.test/api/v1/events");
    expect(
      EventsClient.endpointFor("http://nas.local:8080/polder/").toString(),
      "ws://nas.local:8080/polder/api/v1/events",
    );
  });

  test("authenticates, subscribes, and turns messages into events", () {
    fakeAsync((async) {
      final sockets = <FakeWebSocket>[];
      final client = EventsClient(
        endpoint: Uri.parse("wss://cloud.test/api/v1/events"),
        token: ({required refresh}) async => "access",
        connect: (_) => FakeWebSocket()..also(sockets.add),
      );
      final events = <ServerEvent>[];
      client.events.listen(events.add);
      client.start();
      async.flushMicrotasks();

      final socket = sockets.single;
      expect(socket.sent, [
        {"type": "auth", "token": "access"},
        {"type": "subscribe", "scope": "me"},
      ]);

      socket.serverSends({"type": "ready", "userId": 0});
      socket.serverSends({
        "type": "snapshot",
        "userId": 0,
        "transfers": [transferJson()],
      });
      socket.serverSends({
        "type": "files.changed",
        "userId": 1,
        "dirs": ["/", "/Photos"],
      });
      async.flushMicrotasks();
      expect(client.status, RealtimeStatus.connected);
      expect((events[1] as SnapshotEvent).transfers.single.path, "/Photos/cat.jpg");
      expect((events[2] as FilesChangedEvent).dirs, ["/", "/Photos"]);

      client.subscribe(const ActivityScope.user(id: 7, username: "alice"));
      expect(socket.sent.last, {"type": "subscribe", "scope": "user", "userId": 7});
      client.dispose();
      async.flushMicrotasks();
    });
  });

  test("a rejected token reconnects with a refreshed one", () {
    fakeAsync((async) {
      final sockets = <FakeWebSocket>[];
      final refreshes = <bool>[];
      final client = EventsClient(
        endpoint: Uri.parse("wss://cloud.test/api/v1/events"),
        token: ({required refresh}) async {
          refreshes.add(refresh);
          return refresh ? "renewed" : "stale";
        },
        connect: (_) => FakeWebSocket()..also(sockets.add),
      );
      final events = <ServerEvent>[];
      client.events.listen(events.add);
      client.start();
      async.flushMicrotasks();

      sockets.single.serverCloses(EventsClient.unauthorizedCloseCode);
      async.flushMicrotasks();
      expect(events.last, isA<DisconnectedEvent>());
      expect(client.status, RealtimeStatus.offline);

      async.elapse(const Duration(seconds: 2));
      expect(refreshes, [false, true]);
      expect(sockets.last.sent.first, {"type": "auth", "token": "renewed"});
      client.dispose();
      async.flushMicrotasks();
    });
  });
}

extension<T> on T {
  void also(void Function(T value) action) => action(this);
}
