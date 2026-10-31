import "package:flutter_test/flutter_test.dart";

import "package:polder/util/duration_format.dart";

void main() {
  test("shows minutes and seconds, adding hours only when there are any", () {
    expect(const Duration(seconds: 7).clock, "0:07");
    expect(const Duration(minutes: 12, seconds: 5).clock, "12:05");
    expect(const Duration(hours: 1, minutes: 2, seconds: 3).clock, "1:02:03");
  });
}
