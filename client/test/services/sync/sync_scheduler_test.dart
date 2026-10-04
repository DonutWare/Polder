import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:nomad/services/sync/sync_scheduler.dart";

void main() {
  test("the initial run is deferred out of start and folder events are debounced", () {
    fakeAsync((async) {
      var runs = 0;
      final events = StreamController<void>();
      final scheduler = SyncScheduler(onTrigger: () => runs++)..start([events.stream]);

      expect(runs, 0);
      async.elapse(Duration.zero);
      expect(runs, 1);

      events
        ..add(null)
        ..add(null);
      async.elapse(const Duration(seconds: 3));
      expect(runs, 2);

      scheduler.stop();
      unawaited(events.close());
    });
  });

  test("requested runs are debounced together", () {
    fakeAsync((async) {
      var runs = 0;
      final scheduler = SyncScheduler(onTrigger: () => runs++)..start(const []);
      async.elapse(Duration.zero);

      scheduler
        ..requestRun()
        ..requestRun();
      async.elapse(scheduler.debounce - const Duration(milliseconds: 1));
      expect(runs, 1);
      async.elapse(const Duration(milliseconds: 1));
      expect(runs, 2);

      scheduler.stop();
    });
  });
}
