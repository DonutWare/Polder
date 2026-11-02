import "dart:typed_data";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/services/api/polder_api.dart";

typedef ProgressCallback = void Function(int done, int total);

abstract interface class FileSpaceApi {
  Future<DirectoryListing> list(String path);

  Future<Uint8List?> preview(String path, {int size = 256});

  Future<Uint8List> download(String path, {ProgressCallback? onProgress});

  Future<Uint8List> downloadArchive(String path, {ProgressCallback? onProgress});

  Future<Uri> downloadUrl(String path, {required bool folder});

  Future<({Uri url, Map<String, String> headers})> mediaSource(String path, {required bool inBrowser});

  Future<EditorCapabilities> editorCapabilities();

  Future<EditorSession> startEditorSession(String path, {required String origin});

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
  Future<Uri> downloadUrl(String path, {required bool folder}) async =>
      _api.publicLinkContentUrl(_code, path, folder: folder, token: await _token(), download: !folder);

  @override
  Future<({Uri url, Map<String, String> headers})> mediaSource(String path, {required bool inBrowser}) async {
    final token = await _token();
    return inBrowser
        ? (url: _api.publicLinkContentUrl(_code, path, folder: false, token: token), headers: const <String, String>{})
        : (url: _api.publicLinkContentUrl(_code, path, folder: false), headers: {"X-Polder-Share-Token": token});
  }

  @override
  Future<EditorCapabilities> editorCapabilities() => _api.editorCapabilities();

  @override
  Future<EditorSession> startEditorSession(String path, {required String origin}) async =>
      _api.startPublicLinkEditorSession(_code, await _token(), path, origin: origin);

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
