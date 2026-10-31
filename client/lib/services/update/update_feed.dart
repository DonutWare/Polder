import "dart:convert";

import "package:cryptography/cryptography.dart";
import "package:http/http.dart" as http;

import "package:polder/services/update/update_manifest.dart";
import "package:polder/util/build_channel.dart";

const _configuredPublicKey = String.fromEnvironment("POLDER_UPDATE_PUBLIC_KEY");

const updateSigningConfigured = _configuredPublicKey != "";

class UpdateFeedException implements Exception {
  const UpdateFeedException(this.message);

  final String message;

  @override
  String toString() => "UpdateFeedException: $message";
}

class UpdateFeed {
  UpdateFeed(this._client, {String publicKey = _configuredPublicKey})
    : _publicKey = SimplePublicKey(base64Decode(publicKey), type: KeyPairType.ed25519);

  static const manifestName = "update.json";
  static const signatureName = "update.json.sig";

  final http.Client _client;
  final SimplePublicKey _publicKey;

  Future<UpdateManifest?> fetch(BuildChannel channel) async {
    final manifest = await _download(_url(channel, manifestName));
    if (manifest == null) return null;
    final signature = await _download(_url(channel, signatureName));
    if (signature == null) return null;
    await _verify(manifest, signature);
    final parsed = UpdateManifest.fromJson(jsonDecode(utf8.decode(manifest)) as Map<String, dynamic>);
    if (parsed.channel != channel) throw const UpdateFeedException("manifest is for another channel");
    return parsed;
  }

  static Uri _url(BuildChannel channel, String file) => switch (channel) {
    BuildChannel.nightly => releaseDownloadUrl("nightly", file),
    _ => latestReleaseDownloadUrl(file),
  };

  Future<List<int>?> _download(Uri url) async {
    final response = await _client.get(url);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw UpdateFeedException("${response.statusCode} for $url");
    return response.bodyBytes;
  }

  Future<void> _verify(List<int> manifest, List<int> signature) async {
    final valid = await Ed25519().verify(
      manifest,
      signature: Signature(base64Decode(utf8.decode(signature).trim()), publicKey: _publicKey),
    );
    if (!valid) throw const UpdateFeedException("manifest signature is invalid");
  }
}
