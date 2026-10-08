import "dart:convert";
import "dart:typed_data";
import "dart:ui" as ui;

bool isSvg(Uint8List bytes) => utf8.decode(bytes.take(4096).toList(), allowMalformed: true).contains("<svg");

bool isGif(Uint8List bytes) => bytes.length > 4 && ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == "GIF8";

// Adhere to server limits on sizes
Future<Uint8List> shrinkIcon(Uint8List bytes, {int size = 512}) async {
  if (isSvg(bytes) || isGif(bytes)) return bytes;
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final longest = descriptor.width > descriptor.height ? descriptor.width : descriptor.height;
    if (longest <= size) {
      descriptor.dispose();
      buffer.dispose();
      return bytes;
    }
    final scale = size / longest;
    final codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * scale).round(),
      targetHeight: (descriptor.height * scale).round(),
    );
    final frame = await codec.getNextFrame();
    final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    return png == null ? bytes : png.buffer.asUint8List();
  } on Exception {
    return bytes;
  }
}
