import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/painting.dart";

class NoteImageProvider extends ImageProvider<NoteImageProvider> {
  const NoteImageProvider({required this.identity, required this.load});

  final String identity;
  final Future<Uint8List> Function() load;

  @override
  Future<NoteImageProvider> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(NoteImageProvider key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _decode(key, decode), scale: 1);

  static Future<Codec> _decode(NoteImageProvider key, ImageDecoderCallback decode) async =>
      decode(await ImmutableBuffer.fromUint8List(await key.load()));

  @override
  bool operator ==(Object other) => other is NoteImageProvider && other.identity == identity;

  @override
  int get hashCode => identity.hashCode;
}
