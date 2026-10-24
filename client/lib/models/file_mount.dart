import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/sharing.dart";

part "file_mount.freezed.dart";
part "file_mount.g.dart";

enum FileMountKind { share, federated }

@freezed
abstract class FileMount with _$FileMount {
  const FileMount._();

  const factory FileMount({
    required FileMountKind kind,
    required int shareId,
    required String path,
    @Default(true) bool isDir,
    required String owner,
    @Default("") String ownerName,
    @Default("") String server,
    @Default("") String provider,
    @Default(<String>[]) List<String> groups,
    @Default(SharePermissions.viewOnly) SharePermissions permissions,
    @Default(false) bool canLeave,
    @Default("") String note,
    DateTime? expiresAt,
    required DateTime sharedAt,
  }) = _FileMount;

  factory FileMount.fromJson(Map<String, dynamic> json) => _$FileMountFromJson(json);

  bool get isFederated => kind == FileMountKind.federated;

  String get shownOwner => ownerName.isEmpty || ownerName == owner ? owner : "$ownerName ($owner)";

  bool contains(String path) => path == this.path || path.startsWith("${this.path}/");
}
