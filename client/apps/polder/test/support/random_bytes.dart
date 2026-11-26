import "dart:math";
import "dart:typed_data";

Uint8List randomBytes(int length, {int seed = 42}) {
  final random = Random(seed);
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}
