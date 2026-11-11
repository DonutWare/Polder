import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/services/api/stall_guard_client.dart";

class _ScriptedClient extends http.BaseClient {
  _ScriptedClient(this._respond);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _respond;
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    lastRequest = request;
    if (request case http.Abortable(:final abortTrigger?)) {
      final response = Completer<http.StreamedResponse>();
      unawaited(
        abortTrigger.then((_) {
          if (!response.isCompleted) response.completeError(http.RequestAbortedException(request.url));
        }),
      );
      unawaited(
        _respond(request).then((value) {
          if (!response.isCompleted) response.complete(value);
        }),
      );
      return response.future;
    }
    return _respond(request);
  }
}

void main() {
  final url = Uri.parse("https://cloud.test/api");
  const timeout = Duration(seconds: 10);

  test("a server that never answers fails with a stall once the timeout passes", () {
    fakeAsync((async) {
      final inner = _ScriptedClient((_) => Completer<http.StreamedResponse>().future);
      final client = StallGuardClient(inner, stallTimeout: timeout);
      Object? failure;
      client.send(http.Request("PUT", url)).then<void>((_) {}, onError: (Object error) => failure = error);

      async.elapse(timeout - const Duration(seconds: 1));
      expect(failure, isNull);
      async.elapse(const Duration(seconds: 2));
      expect(failure, isA<ServerStalledException>());
    });
  });

  test("a reader that pauses for a while is not mistaken for a stalled server", () {
    fakeAsync((async) {
      final body = StreamController<List<int>>();
      final inner = _ScriptedClient((request) async {
        unawaited(request.finalize().drain<void>());
        return http.StreamedResponse(body.stream, 200);
      });
      final client = StallGuardClient(inner, stallTimeout: timeout);
      Object? failure;
      final received = <int>[];
      late StreamSubscription<List<int>> reading;
      client.send(http.Request("GET", url)).then((response) {
        reading = response.stream.listen(received.addAll, onError: (Object error) => failure = error);
      });
      async.flushMicrotasks();

      reading.pause();
      async.elapse(timeout * 3);
      reading.resume();
      body.add([1]);
      async.flushMicrotasks();

      expect(failure, isNull);
      expect(received, [1]);
      unawaited(reading.cancel());
    });
  });

  test("a response that keeps sending bytes is never cut off", () {
    fakeAsync((async) {
      final body = StreamController<List<int>>();
      final inner = _ScriptedClient((_) async => http.StreamedResponse(body.stream, 200));
      final client = StallGuardClient(inner, stallTimeout: timeout);
      final received = <int>[];
      Object? failure;
      client.send(http.Request("GET", url)).then((response) {
        response.stream.listen(received.addAll, onError: (Object error) => failure = error);
      });
      async.flushMicrotasks();
      for (var i = 0; i < 5; i++) {
        async.elapse(const Duration(seconds: 8));
        body.add([i]);
        async.flushMicrotasks();
      }
      unawaited(body.close());
      async.elapse(timeout * 2);
      expect(received, [0, 1, 2, 3, 4]);
      expect(failure, isNull);
    });
  });

  test("a response body that stops flowing fails with a stall", () {
    fakeAsync((async) {
      final body = StreamController<List<int>>();
      final inner = _ScriptedClient((request) async {
        final abort = (request as http.Abortable).abortTrigger!;
        unawaited(abort.then((_) => body.addError(http.RequestAbortedException(url))));
        return http.StreamedResponse(body.stream, 200);
      });
      final client = StallGuardClient(inner, stallTimeout: timeout);
      Object? failure;
      client.send(http.Request("GET", url)).then((response) {
        response.stream.listen((_) {}, onError: (Object error) => failure = error);
      });
      async.flushMicrotasks();
      body.add([1]);
      async.elapse(timeout + const Duration(seconds: 1));
      expect(failure, isA<ServerStalledException>());
    });
  });

  test("keeps the request's method, headers and body", () async {
    final inner = _ScriptedClient((request) async {
      final sent = await request.finalize().toBytes();
      return http.StreamedResponse(Stream.value(sent), 200);
    });
    final client = StallGuardClient(inner, stallTimeout: timeout);
    final request = http.Request("POST", url)
      ..headers["x-test"] = "yes"
      ..body = "hello";

    final response = await http.Response.fromStream(await client.send(request));

    expect(inner.lastRequest!.method, "POST");
    expect(inner.lastRequest!.headers["x-test"], "yes");
    expect(response.body, "hello");
  });
}
