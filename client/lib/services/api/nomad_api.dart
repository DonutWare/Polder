import "dart:typed_data";

import "package:chopper/chopper.dart" as chopper;

import "package:nomad/models/activity.dart";
import "package:nomad/models/admin_user_requests.dart";
import "package:nomad/models/change.dart";
import "package:nomad/models/directory_listing.dart";
import "package:nomad/models/file_entry.dart";
import "package:nomad/models/manifest.dart";
import "package:nomad/models/server_settings.dart";
import "package:nomad/models/setup_status.dart";
import "package:nomad/models/token_pair.dart";
import "package:nomad/models/trash.dart";
import "package:nomad/models/upload_session.dart";
import "package:nomad/models/user.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/api/generated/nomad.swagger.dart" as wire;
import "package:nomad/services/api/pending_uploads.dart";
import "package:nomad/services/api/wire_mappers.dart";

class ByteRange {
  const ByteRange(this.offset, this.length);

  final int offset;
  final int length;

  String get header => "bytes=$offset-${offset + length - 1}";
}

class NomadApi {
  NomadApi(this._service);

  final wire.Nomad _service;

  Future<bool> healthz() async => (await _service.health()).body?.status == "ok";

  Future<SetupStatus> setupStatus() async => (await _service.getSetupStatus()).body!.toModel();

  Future<TokenPair> setup({required String username, required String password}) async => (await _service.setup(
    body: wire.CredentialsRequest(username: username, password: password),
  )).body!.toModel();

  Future<TokenPair> login({required String username, required String password, required String deviceName}) async =>
      (await _service.login(
        body: wire.CredentialsRequest(username: username, password: password, deviceName: deviceName),
      )).body!.toModel();

  Future<TokenPair> refresh(String refreshToken) async =>
      (await _service.refresh(body: wire.RefreshRequest(refreshToken: refreshToken))).body!.toModel();

  Future<void> logout(String refreshToken) => _service.logout(body: wire.RefreshRequest(refreshToken: refreshToken));

  Future<User> me() async => (await _service.getMe()).body!.toModel();

  Future<List<User>> listUsers() async => [for (final user in (await _service.listUsers()).body!) user.toModel()];

  Future<User> createUser(CreateUserRequest request) async =>
      (await _service.createUser(body: request.toWire())).body!.toModel();

  Future<User> updateUser(int id, UpdateUserRequest request) async =>
      (await _service.updateUser(userID: id, body: request.toWire())).body!.toModel();

  Future<void> deleteUser(int id) => _service.deleteUser(userID: id);

  Future<DirectoryListing> list(String path) async => (await _service.listFiles(path: path)).body!.toModel();

  Future<FileEntry> stat(String path) async => (await _service.statFile(path: path)).body!.toModel();

  Future<Stream<Uint8List>> openContent(String path, {ByteRange? range, int? ifMatchRev}) async {
    final response = await _service.downloadFile(
      path: path,
      range: range?.header,
      ifMatch: ifMatchRev == null ? null : "\"$ifMatchRev\"",
    );
    return response.body!.map(_asBytes);
  }

  Future<Uint8List> downloadBytes(String path, {void Function(int received, int total)? onProgress}) async =>
      _collect(await _service.downloadFile(path: path), onProgress);

  Future<Uint8List> _collect(
    chopper.Response<Stream<List<int>>> response,
    void Function(int received, int total)? onProgress,
  ) async {
    final total = int.tryParse(response.headers["content-length"] ?? "") ?? -1;
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.body!) {
      bytes.add(chunk);
      onProgress?.call(bytes.length, total);
    }
    return bytes.takeBytes();
  }

  Future<FileEntry> putContent(
    String path,
    Stream<List<int>> body, {
    required int length,
    int baseRev = 0,
    DateTime? mtime,
    String? transferId,
    void Function(int sent, int total)? onProgress,
  }) async {
    var sent = 0;
    final counted = body.map((chunk) {
      sent += chunk.length;
      onProgress?.call(sent, length);
      return chunk;
    });
    final response = await _service.uploadFile(
      path: path,
      baseRev: baseRev,
      mtime: mtime?.toUtc(),
      xNomadTransferId: transferId,
      body: PendingUpload(counted, length),
    );
    return response.body!.toModel();
  }

  Future<FileEntry> mkdir(String path) async =>
      (await _service.makeDirectory(body: wire.PathRequest(path: path))).body!.toModel();

  Future<FileEntry> move({required String from, required String to, int baseRev = -1}) async =>
      (await _service.moveFile(
        body: wire.MoveRequest(from: from, to: to, baseRev: baseRev),
      )).body!.toModel();

  Future<void> delete(String path, {int baseRev = -1}) => _service.deleteFile(path: path, baseRev: baseRev);

  Future<Uint8List?> preview(String path, {int size = 256}) => _thumbnail(
    () => _service.previewFile(
      path: path,
      size: _thumbnailSize(wire.ApiV1FilesPreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<Uint8List?> trashPreview(int id, {int size = 256}) => _thumbnail(
    () => _service.previewTrashItem(
      itemID: id,
      size: _thumbnailSize(wire.ApiV1TrashItemIDPreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<Uint8List?> _thumbnail(Future<chopper.Response<Stream<List<int>>>> Function() request) async {
    try {
      return await _collect(await request(), null);
    } on NotFoundException {
      return null;
    }
  }

  Future<ChangeFeedPage> changes({required int cursor, int limit = 1000}) async =>
      (await _service.listChanges(cursor: cursor, limit: limit)).body!.toModel();

  Future<Manifest> manifest(String path) async => (await _service.getManifest(path: path)).body!.toModel();

  Future<UploadSession> createUpload(UploadRequest request) async =>
      (await _service.createUpload(body: request.toWire())).body!.toModel();

  Future<void> putChunk(String uploadId, String hash, Uint8List bytes) =>
      _service.putChunk(uploadID: uploadId, chunkHash: hash, body: bytes);

  Future<UploadSession> uploadStatus(String uploadId) async =>
      (await _service.getUpload(uploadID: uploadId)).body!.toModel();

  Future<FileEntry> commitUpload(String uploadId) async =>
      (await _service.commitUpload(uploadID: uploadId)).body!.toModel();

  Future<void> abortUpload(String uploadId) => _service.abortUpload(uploadID: uploadId);

  Future<ActivityPage> activity({required ActivityScope scope, int? before, int limit = 50}) async =>
      (await _service.listActivity(user: scope.query, before: before, limit: limit)).body!.toModel();

  Future<List<LiveTransfer>> liveTransfers({required ActivityScope scope}) async => [
    for (final transfer
        in (await _service.listLiveTransfers(user: scope.query)).body!.transfers ?? <wire.LiveTransfer>[])
      transfer.toModel(),
  ];

  Future<TrashListing> listTrash() async => (await _service.listTrash()).body!.toModel();

  Future<FileEntry> restoreFromTrash(int id, {RestoreMode onConflict = RestoreMode.fail}) async =>
      (await _service.restoreTrashItem(
        itemID: id,
        body: wire.RestoreRequest(onConflict: onConflict.toWire()),
      )).body!.toModel();

  Future<Uint8List> downloadFromTrash(int id, {void Function(int received, int total)? onProgress}) async =>
      _collect(await _service.downloadTrashItem(itemID: id), onProgress);

  Future<void> deleteFromTrash(int id) => _service.deleteTrashItem(itemID: id);

  Future<void> emptyTrash() => _service.emptyTrash();

  Future<TrashRetention> trashRetention() async => (await _service.getTrashRetention()).body!.toModel();

  Future<TrashRetention> setTrashRetention(int? days) async =>
      (await _service.setTrashRetention(body: wire.RetentionRequest(days: days))).body!.toModel();

  Future<ServerSettings> serverSettings() async => (await _service.getServerSettings()).body!.toModel();

  Future<ServerSettings> updateServerSettings({int? trashRetentionDays, bool? trashRetentionEnforced}) async =>
      (await _service.updateServerSettings(
        body: wire.ServerSettingsChanges(
          trashRetentionDays: trashRetentionDays,
          trashRetentionEnforced: trashRetentionEnforced,
        ),
      )).body!.toModel();

  static Uint8List _asBytes(List<int> chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk);

  static T _thumbnailSize<T extends Object>(List<T> supported, int? Function(T option) sizeOf, int size) =>
      supported.firstWhere(
        (option) => sizeOf(option) == size,
        orElse: () => throw ArgumentError.value(size, "size", "not a thumbnail size the server renders"),
      );
}
