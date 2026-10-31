import "package:flutter_test/flutter_test.dart";

import "package:media_viewer/media_viewer.dart";

void main() {
  testWidgets("advances after each interval while running and stops when stopped", (tester) async {
    var advances = 0;
    final slideshow = SlideshowController(vsync: const TestVSync(), onAdvance: () => advances++)
      ..interval = const Duration(seconds: 3)
      ..showItem(isVideo: false);
    addTearDown(slideshow.dispose);

    await tester.pump(const Duration(seconds: 5));
    expect(advances, 0);

    slideshow.start();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 16));
    expect(advances, 1);

    slideshow.showItem(isVideo: false);
    slideshow.stop();
    await tester.pump(const Duration(seconds: 5));
    expect(advances, 1);
  });

  testWidgets("waits for a video to finish instead of the interval", (tester) async {
    var advances = 0;
    final slideshow = SlideshowController(vsync: const TestVSync(), onAdvance: () => advances++)
      ..showItem(isVideo: true)
      ..start();
    addTearDown(slideshow.dispose);

    await tester.pump();
    await tester.pump(const Duration(seconds: 30));
    expect(advances, 0);

    slideshow.videoCompleted();
    expect(advances, 1);
  });
}
