import "dart:convert";

import "package:cryptography/cryptography.dart";

import "package:polder/services/update/update_manifest.dart";
import "package:polder/util/build_channel.dart";

Map<String, dynamic> manifestJson({
  String channel = "stable",
  int build = 10,
  String tag = "v1.0.0",
  Map<String, Map<String, dynamic>>? assets,
}) => {
  "channel": channel,
  "version": "1.0.0",
  "build": build,
  "commit": "abc",
  "tag": tag,
  "notesUrl": "https://github.com/DonutWare/Polder/releases/tag/$tag",
  "assets":
      assets ??
      {
        "macos": {"name": "Polder-macOS-1.0.0.zip", "sha256": "00", "size": 1},
        "windows": {"name": "Polder-Windows-1.0.0-Setup.exe", "sha256": "00", "size": 1},
        "linux": {"name": "Polder-Linux-1.0.0.AppImage", "sha256": "00", "size": 1},
      },
};

UpdateManifest manifest({BuildChannel channel = BuildChannel.stable, int build = 10, Set<UpdateTarget>? targets}) =>
    UpdateManifest(
      channel: channel,
      version: "1.0.0",
      build: build,
      tag: channel == BuildChannel.nightly ? "nightly" : "v1.0.0",
      notesUrl: Uri.parse("https://github.com/DonutWare/Polder/releases"),
      assets: {
        for (final target in targets ?? UpdateTarget.values)
          target: UpdateAsset(name: "Polder-${target.name}", sha256: "00", size: 1),
      },
    );

class SigningKey {
  SigningKey._(this._pair, this.publicKey);

  static Future<SigningKey> generate() async {
    final pair = await Ed25519().newKeyPair();
    final publicKey = await pair.extractPublicKey();
    return SigningKey._(pair, base64Encode(publicKey.bytes));
  }

  final SimpleKeyPair _pair;
  final String publicKey;

  Future<String> sign(List<int> message) async => base64Encode((await Ed25519().sign(message, keyPair: _pair)).bytes);
}
