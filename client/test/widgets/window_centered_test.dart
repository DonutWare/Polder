import "package:flutter_test/flutter_test.dart";

import "package:polder/widgets/layout/window_centered.dart";

void main() {
  test("content lines up with the middle of the window when the pane allows it", () {
    final gutters = WindowCentered.gutters(paneLeft: 400, paneWidth: 1200, windowWidth: 1600, contentWidth: 700);
    expect(gutters.left, 50);
    expect(gutters.right, 450);
  });

  test("content stays inside the pane when centring on the window would push it out", () {
    final gutters = WindowCentered.gutters(paneLeft: 480, paneWidth: 760, windowWidth: 1240, contentWidth: 700);
    expect(gutters.left, 16);
    expect(gutters.right, 44);
  });

  test("a narrow pane shrinks the content and keeps the minimum gutters", () {
    final gutters = WindowCentered.gutters(paneLeft: 0, paneWidth: 400, windowWidth: 400, contentWidth: 700);
    expect(gutters.left, 16);
    expect(gutters.right, 16);
  });

  test("a full-width pane centres like before", () {
    final gutters = WindowCentered.gutters(paneLeft: 0, paneWidth: 1000, windowWidth: 1000, contentWidth: 700);
    expect(gutters.left, 150);
    expect(gutters.right, 150);
  });
}
