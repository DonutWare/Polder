import "dart:typed_data";

import "package:flutter/material.dart";

import "package:chopper/chopper.dart" as chopper;
import "package:polder/models/activity.dart";
import "package:polder/models/admin_user_requests.dart";
import "package:polder/models/branding.dart";
import "package:polder/models/change.dart";
import "package:polder/models/directory_listing.dart";
import "package:polder/models/document_editor.dart";
import "package:polder/models/federation.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_links.dart";
import "package:polder/models/link_preview.dart";
import "package:polder/models/file_version.dart";
import "package:polder/models/group.dart";
import "package:polder/models/manifest.dart";
import "package:polder/models/note_item.dart";
import "package:polder/models/search.dart";
import "package:polder/models/server_info.dart";
import "package:polder/models/server_log.dart";
import "package:polder/models/server_settings.dart";
import "package:polder/models/setup_status.dart";
import "package:polder/models/sharing.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/models/trash.dart";
import "package:polder/models/upload_batch.dart";
import "package:polder/models/user.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/federation_mappers.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/pending_uploads.dart";
import "package:polder/services/api/sharing_mappers.dart";
import "package:polder/services/api/wire_mappers.dart";

class ByteRange {
  const ByteRange(this.offset, this.length);

  final int offset;
  final int length;

  String get header => "bytes=$offset-${offset + length - 1}";
}

class PolderApi {
  PolderApi(this._service);

  final wire.Polder _service;

  Future<bool> healthz() async => (await _service.health()).body?.status == "ok";

  Future<Branding> branding() async => (await _service.getBranding()).body!.toModel();

  Future<void> setBrandingIcon(Uint8List bytes) => _service.setBrandingIcon(body: bytes);

  Future<void> removeBrandingIcon() => _service.removeBrandingIcon();

  Future<void> addBrandingBackground(Uint8List bytes) => _service.addBrandingBackground(body: bytes);

  Future<void> removeBrandingBackground(String id) => _service.removeBrandingBackground(imageID: id);

  Future<SetupStatus> setupStatus() async => (await _service.getSetupStatus()).body!.toModel();

  Future<TokenPair> setup({required String username, required String password, String? deviceName}) async =>
      (await _service.setup(
        body: wire.CredentialsRequest(username: username, password: password, deviceName: deviceName),
      )).body!.toModel();

  Future<TokenPair> login({required String username, required String password, required String deviceName}) async =>
      (await _service.login(
        body: wire.CredentialsRequest(username: username, password: password, deviceName: deviceName),
      )).body!.toModel();

  Future<TokenPair> refresh(String refreshToken) async =>
      (await _service.refresh(body: wire.RefreshRequest(refreshToken: refreshToken))).body!.toModel();

  Future<void> logout(String refreshToken) => _service.logout(body: wire.RefreshRequest(refreshToken: refreshToken));

  Future<TokenPair> startSession({required String deviceName}) async =>
      (await _service.startSession(body: wire.SessionRequest(deviceName: deviceName))).body!.toModel();

  Future<User> me() async => (await _service.getMe()).body!.toModel();

  Future<User> setProfile(UserProfile profile) async =>
      (await _service.setProfile(body: profile.toWire())).body!.toModel();

  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      _service.changePassword(
        body: wire.PasswordChange(currentPassword: currentPassword, newPassword: newPassword),
      );

  Future<User> setAppearance({required ThemeMode theme, required Color? accent}) async => (await _service.setAppearance(
    body: wire.Appearance(
      theme: wire.AppearanceTheme.values.byName(theme.name),
      accentColor: accent == null ? null : hexColor(accent),
    ),
  )).body!.toModel();

  Future<User> setAvatar(Uint8List bytes) async => (await _service.setAvatar(body: bytes)).body!.toModel();

  Future<User> removeAvatar() async => (await _service.removeAvatar()).body!.toModel();

  Future<List<User>> listUsers() async => [for (final user in (await _service.listUsers()).body!) user.toModel()];

  Future<User> createUser(CreateUserRequest request) async =>
      (await _service.createUser(body: request.toWire())).body!.toModel();

  Future<User> updateUser(int id, UpdateUserRequest request) async =>
      (await _service.updateUser(userID: id, body: request.toWire())).body!.toModel();

  Future<void> deleteUser(int id) => _service.deleteUser(userID: id);

  Future<DirectoryListing> list(String path) async => (await _service.listFiles(path: path)).body!.toModel();

  Future<FileEntry> stat(String path) async => (await _service.statFile(path: path)).body!.toModel();

  Future<List<FileEntry>> filesById(Iterable<int> ids) async {
    final response = await _service.resolveFiles(body: wire.ResolveRequest(ids: ids.toList()));
    return [for (final entry in response.body!.entries ?? <wire.Entry>[]) entry.toModel()];
  }

  Future<FileLinks> fileLinks(int id) async => (await _service.listFileLinks(id: id)).body!.toModel();

  Future<List<NoteItem>> listNotes(String path) async => [
    for (final item in (await _service.listNotes(path: path)).body!.items ?? <wire.NotesItem>[]) item.toModel(),
  ];

  Future<String?> notesFolder() async => (await _service.getNotesSettings()).body!.path;

  Future<String?> setNotesFolder(String? path) async =>
      (await _service.setNotesSettings(body: wire.NotesSettings(path: path))).body!.path;

  Future<bool> showsSharesInFiles() async => (await _service.getShareDisplaySettings()).body!.showInFiles;

  Future<bool> setShowsSharesInFiles(bool shown) async =>
      (await _service.setShareDisplaySettings(body: wire.ShareDisplaySettings(showInFiles: shown))).body!.showInFiles;

  Future<SearchResults> search(String query, {int limit = 50, int offset = 0}) async =>
      (await _service.searchFiles(q: query, limit: limit, offset: offset)).body!.toModel();

  Future<SearchSuggestions> suggestSearch(String query, int cursor) async =>
      (await _service.suggestSearch(q: query, cursor: cursor)).body!.toModel();

  Future<Stream<Uint8List>> openContent(String path, {ByteRange? range, int? ifMatchRev}) async {
    final response = await _service.downloadFile(
      path: path,
      range: range?.header,
      ifMatch: ifMatchRev == null ? null : "\"$ifMatchRev\"",
    );
    return response.body!.map(_asBytes);
  }

  Future<Stream<Uint8List>> downloadBatch(List<({String path, int rev})> files) async {
    final response = await _service.downloadSyncFiles(
      body: wire.DownloadRequest(
        files: [for (final file in files) wire.DownloadFile(path: file.path, rev: file.rev)],
      ),
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
    final response = await _service.uploadFile(
      path: path,
      baseRev: baseRev,
      mtime: mtime?.toUtc(),
      xPolderTransferId: transferId,
      body: PendingUpload(_counted(body, length, onProgress), length),
    );
    return response.body!.toModel();
  }

  Future<FileEntry> mkdir(String path) async =>
      (await _service.makeDirectory(body: wire.PathRequest(path: path))).body!.toModel();

  Future<FileEntry> move({required String from, required String to, int baseRev = -1}) async =>
      (await _service.moveFile(
        body: wire.MoveRequest(from: from, to: to, baseRev: baseRev),
      )).body!.toModel();

  Future<FileEntry> copy({required String from, required String to}) async => (await _service.copyFile(
    body: wire.CopyRequest(from: from, to: to),
  )).body!.toModel();

  Future<void> delete(String path, {int baseRev = -1}) => _service.deleteFile(path: path, baseRev: baseRev);

  Future<Uint8List?> preview(String path, {int size = 256}) => _thumbnail(
    () => _service.previewFile(
      path: path,
      size: _thumbnailSize(wire.ApiV1FilesPreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<LinkPreview> linkPreview(String url) async => (await _service.getLinkPreview(url: url)).body!.toModel();

  Future<Uint8List?> linkPreviewImage(String url, LinkPreviewImageKind kind) => _thumbnail(
    () => _service.getLinkPreviewImage(url: url, kind: wire.ApiV1LinkPreviewsImageGetKind.values.byName(kind.name)),
  );

  Future<Uint8List?> trashPreview(int id, {int size = 256}) => _thumbnail(
    () => _service.previewTrashItem(
      itemID: id,
      size: _thumbnailSize(wire.ApiV1TrashItemIDPreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<Uint8List?> versionPreview(int id, {int size = 256}) => _thumbnail(
    () => _service.previewFileVersion(
      versionID: id,
      size: _thumbnailSize(wire.ApiV1FilesVersionsVersionIDPreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<VersionListing> fileVersions(String path) async =>
      (await _service.listFileVersions(path: path)).body!.toModel();

  Future<Uint8List> downloadVersion(int id, {void Function(int received, int total)? onProgress}) async =>
      _collect(await _service.downloadFileVersion(versionID: id), onProgress);

  Future<FileEntry> restoreVersion(int id, {int baseRev = 0}) async => (await _service.restoreFileVersion(
    versionID: id,
    body: wire.VersionRestoreRequest(baseRev: baseRev),
  )).body!.toModel();

  Future<void> deleteVersion(int id) => _service.deleteFileVersion(versionID: id);

  Future<VersionRetention> versionSettings() async => (await _service.getVersionSettings()).body!.toModel();

  Future<VersionRetention> setVersionSettings(VersionPreferences preferences) async =>
      (await _service.setVersionSettings(
        body: wire.VersionPreferences(
          enabled: preferences.enabled,
          keepAllHours: preferences.keepAllHours,
          maxAgeDays: preferences.maxAgeDays,
          maxPerFile: preferences.maxPerFile,
        ),
      )).body!.toModel();

  Future<Uint8List?> _thumbnail(Future<chopper.Response<Stream<List<int>>>> Function() request) async {
    try {
      return await _collect(await request(), null);
    } on NotFoundException {
      return null;
    }
  }

  Future<EditorCapabilities> editorCapabilities() async => (await _service.getOfficeCapabilities()).body!.toModel();

  Future<EditorSession> startEditorSession(String path, {required String origin, int? versionId}) async =>
      (await _service.startOfficeSession(
        body: wire.OfficeSessionRequest(path: path, origin: origin, versionId: versionId),
      )).body!.toModel();

  Future<ChangeFeedPage> changes({required int cursor, int limit = 1000}) async =>
      (await _service.listChanges(cursor: cursor, limit: limit)).body!.toModel();

  Future<Manifest> manifest(String path) async => (await _service.getManifest(path: path)).body!.toModel();

  Future<UploadBatchStatus> createUploadBatch(List<UploadRequest> files) async =>
      (await _service.createUploadBatch(body: wire.BatchRequest(files: [for (final file in files) file.toWire()])))
          .body!
          .toModel();

  Future<UploadBatchStatus> streamUploadBatch(String batchId, Stream<List<int>> body, {required int length}) async =>
      (await _service.streamUploadBatch(batchID: batchId, body: PendingUpload(body, length))).body!.toModel();

  Future<void> abortUploadBatch(String batchId) => _service.abortUploadBatch(batchID: batchId);

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

  Future<TrashRetention> setTrashRetention(TrashPreferences preferences) async => (await _service.setTrashRetention(
    body: wire.TrashPreferences(enabled: preferences.enabled, days: preferences.days),
  )).body!.toModel();

  Future<ServerSettings> serverSettings() async => (await _service.getServerSettings()).body!.toModel();

  Future<ServerInfo> serverInfo() async => (await _service.getServerInfo()).body!.toModel();

  Future<ServerSettings> updateServerSettings({
    bool? trashEnabled,
    int? trashRetentionDays,
    bool? searchContentEnabled,
    bool? ocrEnabled,
    List<String>? ocrLanguages,
    int? ocrMaxPages,
    String? instanceName,
    String? welcomeMessage,
    String? accentColor,
    bool? versionsEnabled,
    int? versionsKeepAllHours,
    int? versionsMaxAgeDays,
    int? versionsMaxPerFile,
    bool? federationEnabled,
  }) async => (await _service.updateServerSettings(
    body: wire.ServerSettingsChanges(
      federationEnabled: federationEnabled,
      versionsEnabled: versionsEnabled,
      versionsKeepAllHours: versionsKeepAllHours,
      versionsMaxAgeDays: versionsMaxAgeDays,
      versionsMaxPerFile: versionsMaxPerFile,
      trashEnabled: trashEnabled,
      trashRetentionDays: trashRetentionDays,
      searchContentEnabled: searchContentEnabled,
      ocrEnabled: ocrEnabled,
      ocrLanguages: ocrLanguages,
      ocrMaxPages: ocrMaxPages,
      instanceName: instanceName,
      welcomeMessage: welcomeMessage,
      accentColor: accentColor,
    ),
  )).body!.toModel();

  Future<TextExtractionStatus> textExtractionStatus() async =>
      (await _service.getSearchStatus()).body!.extraction.toModel();

  Future<int> regeneratePreviews() async => (await _service.regeneratePreviews()).body!.files;

  Future<ServerLogPage> serverLogs({
    ServerLogFilter filter = const ServerLogFilter(),
    String? before,
    int limit = 100,
  }) async => (await _service.listLogs(
    level: wire.ApiV1AdminLogsGetLevel.values.firstWhere((level) => level.value == filter.minLevel.name),
    component: filter.component,
    q: filter.query.isEmpty ? null : filter.query,
    before: before,
    limit: limit,
  )).body!.toModel();

  Future<List<String>> logComponents() async => (await _service.listLogComponents()).body!.components ?? const [];

  Future<List<ServerLogFile>> logFiles() async => [
    for (final file in (await _service.listLogFiles()).body!.files ?? <wire.ServerLogFile>[]) file.toModel(),
  ];

  Future<Uint8List> downloadLogFile(String name, {void Function(int received, int total)? onProgress}) async =>
      _collect(await _service.downloadLogFile(name: name), onProgress);

  Future<List<Group>> groups({GroupScope scope = GroupScope.mine}) async => [
    for (final group in (await _service.listGroups(
      scope: wire.ApiV1GroupsGetScope.values.firstWhere((option) => option.value == scope.name),
    )).body!)
      group.toModel(),
  ];

  Future<GroupDetails> group(int id) async => (await _service.getGroup(groupID: id)).body!.toModel();

  Future<Group> createGroup(String name) async =>
      (await _service.createGroup(body: wire.GroupNameRequest(name: name))).body!.toModel();

  Future<Group> renameGroup(int id, String name) async => (await _service.renameGroup(
    groupID: id,
    body: wire.GroupNameRequest(name: name),
  )).body!.toModel();

  Future<void> deleteGroup(int id) => _service.deleteGroup(groupID: id);

  Future<GroupDetails> addGroupMember(int groupId, int userId, GroupRole role) async => (await _service.addGroupMember(
    groupID: groupId,
    body: wire.NewMember(userId: userId, role: wire.NewMemberRole.values.byName(role.name)),
  )).body!.toModel();

  Future<GroupDetails> setGroupMemberRole(int groupId, int userId, GroupRole role) async =>
      (await _service.setGroupMemberRole(
        groupID: groupId,
        userID: userId,
        body: wire.RoleChange(role: wire.RoleChangeRole.values.byName(role.name)),
      )).body!.toModel();

  Future<void> removeGroupMember(int groupId, int userId) =>
      _service.removeGroupMember(groupID: groupId, userID: userId);

  Future<List<OutgoingShare>> groupShares(int groupId) async => [
    for (final share in (await _service.listGroupShares(groupID: groupId)).body!) share.toModel(),
  ];

  Future<ShareTargets> searchShareTargets(String query) async =>
      (await _service.searchDirectory(q: query)).body!.toModel();

  Future<List<OutgoingShare>> outgoingShares({int? fileId}) async => [
    for (final share in (await _service.listOutgoingShares(fileId: fileId)).body!) share.toModel(),
  ];

  Future<List<IncomingShare>> incomingShares() async => [
    for (final share in (await _service.listIncomingShares()).body!) share.toModel(),
  ];

  Future<OutgoingShare> share({
    required int fileId,
    required ShareTarget recipient,
    required SharePermissions permissions,
    DateTime? expiresAt,
    String note = "",
  }) async => (await _service.createShare(
    body: wire.NewShare(
      fileId: fileId,
      recipient: wire.RecipientRef(id: recipient.id, kind: wire.RecipientRefKind.values.byName(recipient.kind.name)),
      permissions: permissions.toWire(),
      expiresAt: expiresAt?.toUtc(),
      note: note.isEmpty ? null : note,
    ),
  )).body!.toModel();

  Future<OutgoingShare> updateShare(
    int id, {
    SharePermissions? permissions,
    DateTime? expiresAt,
    bool removeExpiry = false,
    String? note,
  }) async => (await _service.updateShare(
    shareID: id,
    body: wire.ShareChanges(
      permissions: permissions?.toWire(),
      expiresAt: expiresAt?.toUtc(),
      removeExpiry: removeExpiry ? true : null,
      note: note,
    ),
  )).body!.toModel();

  Future<void> removeShare(int id) => _service.deleteShare(shareID: id);

  Future<List<AppPassword>> appPasswords() async => [
    for (final password in (await _service.listAppPasswords()).body!) password.toModel(),
  ];

  Future<CreatedAppPassword> createAppPassword({
    required String name,
    required String currentPassword,
    bool readOnly = false,
  }) async => (await _service.createAppPassword(
    body: wire.AppPasswordRequest(name: name, currentPassword: currentPassword, readOnly: readOnly),
  )).body!.toModel();

  Future<void> deleteAppPassword(int id) => _service.deleteAppPassword(appPasswordID: id);

  Future<FederationStatus> federationStatus() async => (await _service.getFederationStatus()).body!.toModel();

  Future<List<TrustedServer>> trustedServers() async => [
    for (final server in (await _service.listTrustedServers()).body!) server.toModel(),
  ];

  Future<TrustedServer> addTrustedServer(
    String remote, {
    bool allowPrivateNetwork = false,
    bool skipAddressCheck = false,
  }) async => (await _service.addTrustedServer(
    body: wire.TrustedServerRequest(
      remote: remote,
      allowPrivateNetwork: allowPrivateNetwork,
      skipAddressCheck: skipAddressCheck,
    ),
  )).body!.toModel();

  Future<TrustedServer> updateTrustedServer(
    int id, {
    required bool allowPrivateNetwork,
    required bool skipAddressCheck,
  }) async => (await _service.updateTrustedServer(
    serverID: id,
    body: wire.ServerOptions(allowPrivateNetwork: allowPrivateNetwork, skipAddressCheck: skipAddressCheck),
  )).body!.toModel();

  Future<List<FederationInvite>> federationInvites() async => [
    for (final invite in (await _service.listFederationInvites()).body!) invite.toModel(),
  ];

  Future<FederationInvite> createFederationInvite() async => (await _service.createFederationInvite()).body!.toModel();

  Future<void> revokeFederationInvite(int id) => _service.revokeFederationInvite(id: id);

  Future<FederationContact> acceptFederationInvite({required String token, required String provider}) async =>
      (await _service.acceptFederationInvite(
        body: wire.AcceptInviteRequest(token: token.trim(), provider: provider.trim()),
      )).body!.toModel();

  Future<List<FederationContact>> federationContacts() async => [
    for (final contact in (await _service.listFederationContacts()).body!) contact.toModel(),
  ];

  Future<void> removeFederationContact(int id) => _service.removeFederationContact(id: id);

  Future<TrustedServer> refreshTrustedServer(int id) async =>
      (await _service.refreshTrustedServer(serverID: id)).body!.toModel();

  Future<void> removeTrustedServer(int id) => _service.removeTrustedServer(serverID: id);

  Future<List<FederatedShare>> federatedShares({int? fileId}) async => [
    for (final share in (await _service.listOutgoingFederatedShares(fileId: fileId)).body!) share.toModel(),
  ];

  Future<FederatedShare> shareFederated({
    required int fileId,
    required String recipient,
    required SharePermissions permissions,
    DateTime? expiresAt,
  }) async => (await _service.createFederatedShare(
    body: wire.NewOutgoingShare(
      fileId: fileId,
      recipient: recipient.trim(),
      permissions: permissions.toWire(),
      expiresAt: expiresAt?.toUtc(),
    ),
  )).body!.toModel();

  Future<FederatedShare> updateFederatedShare(
    int id, {
    SharePermissions? permissions,
    DateTime? expiresAt,
    bool removeExpiry = false,
  }) async => (await _service.updateFederatedShare(
    shareID: id,
    body: wire.OutgoingShareChanges(
      permissions: permissions?.toWire(),
      expiresAt: expiresAt?.toUtc(),
      noExpiry: removeExpiry ? true : null,
    ),
  )).body!.toModel();

  Future<void> removeFederatedShare(int id) => _service.deleteFederatedShare(shareID: id);

  Future<List<IncomingFederatedShare>> incomingFederatedShares() async => [
    for (final share in (await _service.listIncomingFederatedShares()).body!) share.toModel(),
  ];

  Future<IncomingFederatedShare> acceptFederatedShare(int id) async =>
      (await _service.acceptFederatedShare(shareID: id)).body!.toModel();

  Future<void> removeIncomingFederatedShare(int id) => _service.removeIncomingFederatedShare(shareID: id);

  Future<List<ShareLink>> shareLinks({int? fileId}) async => [
    for (final link in (await _service.listShareLinks(fileId: fileId)).body!) link.toModel(),
  ];

  Future<ShareLink> createShareLink(int fileId, LinkOptions options) async => (await _service.createShareLink(
    body: wire.NewShareLink(
      fileId: fileId,
      permissions: options.permissions.toWire(),
      password: options.password,
      expiresAt: options.expiresAt?.toUtc(),
    ),
  )).body!.toModel();

  Future<ShareLink> updateShareLink(int id, LinkOptions options) async => (await _service.updateShareLink(
    linkID: id,
    body: wire.LinkChanges(
      permissions: options.permissions.toWireChanges(),
      password: options.password,
      removePassword: options.removePassword ? true : null,
      expiresAt: options.expiresAt?.toUtc(),
      removeExpiry: options.removeExpiry ? true : null,
    ),
  )).body!.toModel();

  Future<void> deleteShareLink(int id) => _service.deleteShareLink(linkID: id);

  Future<LinkMatch> matchShareLink(String code) async => (await _service.matchShareLink(code: code)).body!.toModel();

  Future<PublicLinkInfo> publicLink(String code) async => (await _service.getPublicLink(code: code)).body!.toModel();

  Future<PublicLinkUnlock> unlockPublicLink(String code, {String? password}) async => (await _service.unlockPublicLink(
    code: code,
    body: wire.UnlockRequest(password: password),
  )).body!.toModel();

  Future<DirectoryListing> listPublicLink(String code, String token, String path) async =>
      (await _service.listPublicLinkFiles(code: code, path: path, xPolderShareToken: token)).body!.toModel();

  Future<Uint8List> downloadFromPublicLink(
    String code,
    String token,
    String path, {
    void Function(int received, int total)? onProgress,
  }) async =>
      _collect(await _service.downloadPublicLinkFile(code: code, path: path, xPolderShareToken: token), onProgress);

  Future<Uint8List> downloadPublicLinkArchive(
    String code,
    String token,
    String path, {
    void Function(int received, int total)? onProgress,
  }) async =>
      _collect(await _service.downloadPublicLinkArchive(code: code, path: path, xPolderShareToken: token), onProgress);

  Future<Uint8List?> publicLinkPreview(String code, String token, String path, {int size = 256}) => _thumbnail(
    () => _service.previewPublicLinkFile(
      code: code,
      path: path,
      xPolderShareToken: token,
      size: _thumbnailSize(wire.ApiV1PublicLinksCodePreviewGetSize.values, (option) => option.value, size),
    ),
  );

  Future<FileEntry> putPublicLinkContent(
    String code,
    String token,
    String path,
    Stream<List<int>> body, {
    required int length,
    String? transferId,
    void Function(int sent, int total)? onProgress,
  }) async => (await _service.uploadPublicLinkFile(
    code: code,
    path: path,
    xPolderShareToken: token,
    xPolderTransferId: transferId,
    body: PendingUpload(_counted(body, length, onProgress), length),
  )).body!.toModel();

  static Stream<List<int>> _counted(
    Stream<List<int>> body,
    int length,
    void Function(int sent, int total)? onProgress,
  ) {
    var sent = 0;
    return body.map((chunk) {
      sent += chunk.length;
      onProgress?.call(sent, length);
      return chunk;
    });
  }

  static Uint8List _asBytes(List<int> chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk);

  static T _thumbnailSize<T extends Object>(List<T> supported, int? Function(T option) sizeOf, int size) =>
      supported.firstWhere(
        (option) => sizeOf(option) == size,
        orElse: () => throw ArgumentError.value(size, "size", "not a thumbnail size the server renders"),
      );
}
