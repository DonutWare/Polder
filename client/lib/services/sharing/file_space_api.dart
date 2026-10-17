import "dart:typed_data";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/services/api/polder_api.dart";

typedef ProgressCallback = void Function(int done, int total);

abstract interface class FileSpaceApi {
  Future<DirectoryListing> list(String path);

  Future<Uint8List?> preview(String path, {int size = 256});

  Future<Uint8List> download(String path, {ProgressCallback? onProgress});

  Future<Uint8List> downloadArchive(String path, {ProgressCallback? onProgress});

  Future<FileEntry> upload(
    String path,
    Stream<List<int>> body, {
    required int length,
    String? transferId,
    ProgressCallback? onProgress,
  });

  Future<FileEntry> mkdir(String path);

  Future<FileEntry> move({required String from, required String to, int baseRev = -1});

  Future<void> delete(String path, {int baseRev = -1});
}

class ShareSpaceApi implements FileSpaceApi {
  const ShareSpaceApi(this._api, this._shareId);

  final PolderApi _api;
  final int _shareId;

  @override
  Future<DirectoryListing> list(String path) => _api.listShare(_shareId, path);

  @override
  Future<Uint8List?> preview(String path, {int size = 256}) => _api.sharePreview(_shareId, path, size: size);

  @override
  Future<Uint8List> download(String path, {ProgressCallback? onProgress}) =>
      _api.downloadFromShare(_shareId, path, onProgress: onProgress);

  @override
  Future<Uint8List> downloadArchive(String path, {ProgressCallback? onProgress}) =>
      _api.downloadShareArchive(_shareId, path, onProgress: onProgress);

  @override
  Future<FileEntry> upload(
    String path,
    Stream<List<int>> body, {
    required int length,
    String? transferId,
    ProgressCallback? onProgress,
  }) => _api.putShareContent(_shareId, path, body, length: length, transferId: transferId, onProgress: onProgress);

  @override
  Future<FileEntry> mkdir(String path) => _api.mkdirInShare(_shareId, path);

  @override
  Future<FileEntry> move({required String from, required String to, int baseRev = -1}) =>
      _api.moveInShare(_shareId, from: from, to: to, baseRev: baseRev);

  @override
  Future<void> delete(String path, {int baseRev = -1}) => _api.deleteInShare(_shareId, path, baseRev: baseRev);
}

class LinkSpaceApi implements FileSpaceApi {
  const LinkSpaceApi(this._api, this._code, this._token);

  final PolderApi _api;
  final String _code;
  final Future<String> Function() _token;

  @override
  Future<DirectoryListing> list(String path) async => _api.listPublicLink(_code, await _token(), path);

  @override
  Future<Uint8List?> preview(String path, {int size = 256}) async =>
      _api.publicLinkPreview(_code, await _token(), path, size: size);

  @override
  Future<Uint8List> download(String path, {ProgressCallback? onProgress}) async =>
      _api.downloadFromPublicLink(_code, await _token(), path, onProgress: onProgress);

  @override
  Future<Uint8List> downloadArchive(String path, {ProgressCallback? onProgress}) async =>
      _api.downloadPublicLinkArchive(_code, await _token(), path, onProgress: onProgress);

  @override
  Future<FileEntry> upload(
    String path,
    Stream<List<int>> body, {
    required int length,
    String? transferId,
    ProgressCallback? onProgress,
  }) async => _api.putPublicLinkContent(
    _code,
    await _token(),
    path,
    body,
    length: length,
    transferId: transferId,
    onProgress: onProgress,
  );

  @override
  Future<FileEntry> mkdir(String path) => throw UnsupportedError("links cannot create folders");

  @override
  Future<FileEntry> move({required String from, required String to, int baseRev = -1}) =>
      throw UnsupportedError("links cannot move files");

  @override
  Future<void> delete(String path, {int baseRev = -1}) => throw UnsupportedError("links cannot delete files");
}
