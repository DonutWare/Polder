import "dart:io";

import "package:crypto/crypto.dart";
import "package:http/http.dart" as http;
import "package:path/path.dart" as p;

import "package:polder/services/update/update_manifest.dart";

class UpdateDownloadException implements Exception {
  const UpdateDownloadException(this.message);

  final String message;

  @override
  String toString() => "UpdateDownloadException: $message";
}

class UpdateDownloader {
  UpdateDownloader(this._client, this._root);

  final http.Client _client;
  final Future<Directory> Function() _root;

  Future<File> download(
    UpdateManifest manifest,
    UpdateAsset asset, {
    required void Function(double progress) onProgress,
  }) async {
    final directory = await _directoryFor(manifest.build);
    final file = File(p.join(directory.path, asset.name));
    if (await file.exists() && await _matches(file, asset)) return file;

    final partial = File("${file.path}.part");
    await _fetch(manifest.downloadUrl(asset), partial, asset.size, onProgress);
    if (!await _matches(partial, asset)) {
      await partial.delete();
      throw UpdateDownloadException("${asset.name} does not match the published checksum");
    }
    return partial.rename(file.path);
  }

  Future<Directory> _directoryFor(int build) async {
    final root = await _root();
    final directory = Directory(p.join(root.path, "$build"));
    if (await root.exists()) {
      await for (final entry in root.list()) {
        if (entry.path != directory.path) await entry.delete(recursive: true);
      }
    }
    return directory.create(recursive: true);
  }

  Future<void> _fetch(Uri url, File target, int size, void Function(double progress) onProgress) async {
    final response = await _client.send(http.Request("GET", url));
    if (response.statusCode != 200) throw UpdateDownloadException("${response.statusCode} for $url");
    final sink = target.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(size == 0 ? 0 : (received / size).clamp(0, 1));
      }
    } finally {
      await sink.close();
    }
  }

  static Future<bool> _matches(File file, UpdateAsset asset) async {
    if (await file.length() != asset.size) return false;
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString() == asset.sha256.toLowerCase();
  }
}
