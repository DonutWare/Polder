import "package:flutter_test/flutter_test.dart";

import "package:nomad/util/throughput_meter.dart";

void main() {
  var now = DateTime(2026);
  late ThroughputMeter meter;

  void advance(Duration duration) => now = now.add(duration);

  setUp(() {
    now = DateTime(2026);
    meter = ThroughputMeter(clock: () => now);
  });

  test("nothing measured reads as zero", () {
    expect(meter.rate, 0);
  });

  test("a first burst is spread over at least a second", () {
    meter.add(1000);

    expect(meter.rate, 1000);
  });

  test("many small transfers average into one steady rate", () {
    for (var i = 0; i < 40; i++) {
      meter.add(i.isEven ? 1000 : 3000);
      advance(const Duration(milliseconds: 100));
    }

    expect(meter.rate, closeTo(20000, 500));
  });

  test("a short pause lowers the rate instead of dropping it to zero", () {
    for (var i = 0; i < 50; i++) {
      meter.add(1000);
      advance(const Duration(milliseconds: 100));
    }
    advance(const Duration(seconds: 2));

    expect(meter.rate, inInclusiveRange(5000, 7000));
  });

  test("the rate falls to zero once the window holds nothing", () {
    meter.add(1000);
    advance(const Duration(seconds: 6));

    expect(meter.rate, 0);

    meter.add(500);
    expect(meter.rate, 500);
  });
}
