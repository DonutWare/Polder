import "dart:io";
import "dart:ui" as ui;

import "package:flutter_svg/flutter_svg.dart";
import "package:flutter_test/flutter_test.dart";
import "package:polder_tools/icon_artwork.dart";

const _iconSize = 1024;
const _faviconSize = 48;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("generate app icons", () async {
    final apps = Directory("../apps");
    final changed = <AppArtwork>{};
    for (final artwork in appArtworks) {
      final appDir = Directory("${apps.path}/${artwork.app}");
      if (!appDir.existsSync()) continue;
      for (final channel in IconChannel.values) {
        final iconDir = Directory("${appDir.path}/assets/icon${channel == IconChannel.dev ? "/dev" : ""}")
          ..createSync(recursive: true);
        for (final variant in IconVariant.values) {
          final base = "${iconDir.path}/${variant.fileName}";
          if (await _writeIcon(iconSvg(artwork, variant, channel), base)) changed.add(artwork);
        }
      }
    }
    await _writeFavicons(Directory("${apps.path}/polder/web"), changed);
  });
}

Future<bool> _writeIcon(String svg, String base) async {
  final svgFile = File("$base.svg");
  final pngFile = File("$base.png");
  final content = "$svg\n";
  if (svgFile.existsSync() && svgFile.readAsStringSync() == content && pngFile.existsSync()) return false;
  svgFile.writeAsStringSync(content);
  await _writePng(svg, _iconSize, pngFile.path);
  return true;
}

Future<void> _writeFavicons(Directory web, Set<AppArtwork> changed) async {
  if (!web.existsSync()) return;
  for (final artwork in appArtworks) {
    final name = artwork.favicon;
    if (name == null) continue;
    final file = File("${web.path}/$name.png");
    if (file.existsSync() && !changed.contains(artwork)) continue;
    await _writePng(iconSvg(artwork, IconVariant.appIcon, IconChannel.prod), _faviconSize, file.path);
  }
}

Future<void> _writePng(String svg, int size, String path) async {
  final loaded = await vg.loadPicture(SvgStringLoader(svg), null);
  final recorder = ui.PictureRecorder();
  final scale = size / _iconSize;
  ui.Canvas(recorder)
    ..scale(scale)
    ..drawPicture(loaded.picture);
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
  loaded.picture.dispose();
}
