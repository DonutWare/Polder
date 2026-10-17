import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/branding.dart";
import "package:polder/models/file_entry.dart";

part "sharing.freezed.dart";

@freezed
abstract class SharePermissions with _$SharePermissions {
  const SharePermissions._();

  const factory SharePermissions({
    @Default(false) bool create,
    @Default(false) bool edit,
    @Default(false) bool delete,
  }) = _SharePermissions;

  static const viewOnly = SharePermissions();

  bool get isViewOnly => !create && !edit && !delete;

  bool get isEditor => create && edit && delete;

  SharePermissions forEntry({required bool isDir}) => isDir ? this : copyWith(create: false, delete: false);
}

enum ShareTargetKind { user, group }

@freezed
abstract class LinkPermissions with _$LinkPermissions {
  const LinkPermissions._();

  const factory LinkPermissions({@Default(true) bool view, @Default(true) bool download, @Default(false) bool upload}) =
      _LinkPermissions;

  bool get isUploadOnly => upload && !view;

  bool get isValid => (view || upload) && (!download || view);
}

@freezed
abstract class ShareTarget with _$ShareTarget {
  const ShareTarget._();

  const factory ShareTarget({
    required ShareTargetKind kind,
    required int id,
    required String name,
    String? username,
    ServerImage? avatar,
    int? memberCount,
  }) = _ShareTarget;

  bool get isGroup => kind == ShareTargetKind.group;
}

@freezed
abstract class SharedFile with _$SharedFile {
  const SharedFile._();

  const factory SharedFile({required int id, @Default("") String name, @Default(false) bool isDir}) = _SharedFile;

  factory SharedFile.of(FileEntry entry) => SharedFile(id: entry.id, name: entry.name, isDir: entry.isDir);
}

@freezed
abstract class OutgoingShare with _$OutgoingShare {
  const OutgoingShare._();

  const factory OutgoingShare({
    required int id,
    required SharedFile file,
    required ShareTarget owner,
    required ShareTarget recipient,
    required SharePermissions permissions,
    DateTime? expiresAt,
    @Default("") String note,
    @Default(true) bool available,
    @Default(false) bool canChange,
    @Default(false) bool canRemove,
  }) = _OutgoingShare;

  bool get isManageable => canChange || canRemove;
}

@freezed
abstract class IncomingShare with _$IncomingShare {
  const factory IncomingShare({
    required int id,
    required ShareTarget owner,
    @Default(false) bool direct,
    @Default(<ShareTarget>[]) List<ShareTarget> groups,
    required SharePermissions permissions,
    DateTime? expiresAt,
    @Default("") String note,
    required FileEntry entry,
  }) = _IncomingShare;
}

@freezed
abstract class ShareLink with _$ShareLink {
  const ShareLink._();

  const factory ShareLink({
    required int id,
    required String code,
    required SharedFile file,
    required LinkPermissions permissions,
    @Default(false) bool hasPassword,
    DateTime? expiresAt,
    @Default(true) bool available,
  }) = _ShareLink;

  bool isExpired(DateTime now) => expiresAt != null && !now.isBefore(expiresAt!);

  String url(String serverUrl) => "$serverUrl/share/$code";
}

@freezed
abstract class PublicLinkInfo with _$PublicLinkInfo {
  const factory PublicLinkInfo({
    required bool needsPassword,
    required LinkPermissions permissions,
    String? name,
    ShareTarget? owner,
  }) = _PublicLinkInfo;
}

@freezed
abstract class PublicLinkUnlock with _$PublicLinkUnlock {
  const factory PublicLinkUnlock({
    required String token,
    required DateTime expiresAt,
    required PublicLinkInfo info,
    required FileEntry root,
  }) = _PublicLinkUnlock;
}

@freezed
abstract class LinkMatch with _$LinkMatch {
  const factory LinkMatch({String? ownPath, int? shareId, String? path}) = _LinkMatch;
}

@freezed
abstract class ShareTargets with _$ShareTargets {
  const factory ShareTargets({
    @Default(<ShareTarget>[]) List<ShareTarget> users,
    @Default(<ShareTarget>[]) List<ShareTarget> groups,
  }) = _ShareTargets;
}

@freezed
abstract class LinkOptions with _$LinkOptions {
  const factory LinkOptions({
    @Default(LinkPermissions()) LinkPermissions permissions,
    String? password,
    @Default(false) bool removePassword,
    DateTime? expiresAt,
    @Default(false) bool removeExpiry,
  }) = _LinkOptions;
}
