import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/services/offline/sync_lane.dart";

void main() {
  test("kicks during a run lead to exactly one more run", () {
    fakeAsync((async) {
      var runs = 0;
      final gate = Completer<void>();
      final lane = SyncLane(() async {
        runs++;
        if (runs == 1) await gate.future;
        return null;
      });

      lane.kick();
      async.elapse(const Duration(seconds: 1));
      lane
        ..kick()
        ..kick();
      async.elapse(const Duration(seconds: 1));
      gate.complete();
      async.elapse(const Duration(seconds: 1));

      expect(runs, 2);
      lane.dispose();
    });
  });

  test("a failing run is retried with backoff and remembers the error", () {
    fakeAsync((async) {
      var runs = 0;
      final lane = SyncLane(() async {
        runs++;
        if (runs == 1) throw StateError("unreachable");
        return null;
      });

      unawaited(lane.run());
      async.flushMicrotasks();
      expect(lane.lastError, isA<StateError>());

      async.elapse(const Duration(seconds: 6));

      expect(runs, 2);
      expect(lane.lastError, isNull);
      lane.dispose();
    });
  });

  test("work that asks for a later retry runs again at that time", () {
    fakeAsync((async) {
      var runs = 0;
      final lane = SyncLane(() async {
        runs++;
        return runs == 1 ? DateTime.now().add(const Duration(seconds: 30)) : null;
      });

      unawaited(lane.run());
      async.elapse(const Duration(seconds: 29));
      expect(runs, 1);
      async.elapse(const Duration(seconds: 2));

      expect(runs, 2);
      lane.dispose();
    });
  });

  test("a run that hangs is abandoned and retried", () {
    fakeAsync((async) {
      var runs = 0;
      final lane = SyncLane(() {
        runs++;
        return runs == 1 ? Completer<DateTime?>().future : Future.value();
      }, watchdog: const Duration(minutes: 1));

      unawaited(lane.run());
      async.elapse(const Duration(minutes: 2));

      expect(runs, 2);
      expect(lane.running, isFalse);
      lane.dispose();
    });
  });

  test("nothing runs without a network", () {
    fakeAsync((async) {
      var runs = 0;
      final lane = SyncLane(() async {
        runs++;
        return null;
      }, canRun: () async => false);

      lane.kick();
      async.elapse(const Duration(minutes: 10));

      expect(runs, 0);
      lane.dispose();
    });
  });
}
