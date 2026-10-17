import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/wire_mappers.dart";

GroupRole _role(String? value) => GroupRole.values.asNameMap()[value] ?? GroupRole.viewer;

extension SharePermissionsToModel on wire.SharePermissions {
  SharePermissions toModel() => SharePermissions(create: create ?? false, edit: edit ?? false, delete: delete ?? false);
}

extension SharePermissionsToWire on SharePermissions {
  wire.SharePermissions toWire() => wire.SharePermissions(create: create, edit: edit, delete: delete);
}

extension LinkPermissionsToModel on wire.LinkPermissions {
  LinkPermissions toModel() => LinkPermissions(view: view, download: download, upload: upload);
}

extension LinkPermissionsToWire on LinkPermissions {
  wire.LinkPermissions toWire() => wire.LinkPermissions(view: view, download: download, upload: upload);

  wire.LinkPermissionChanges toWireChanges() =>
      wire.LinkPermissionChanges(view: view, download: download, upload: upload);
}

ShareTarget _userTarget({required int id, required String name, String? username, wire.Avatar? avatar}) =>
    ShareTarget(kind: ShareTargetKind.user, id: id, name: name, username: username, avatar: avatar?.toModel());

ShareTarget _groupTarget({required int id, required String name, int? memberCount}) =>
    ShareTarget(kind: ShareTargetKind.group, id: id, name: name, memberCount: memberCount);

extension UserSummaryToModel on wire.UserSummary {
  ShareTarget toModel() => _userTarget(id: id, name: displayName, username: username, avatar: avatar);
}

extension GroupToModel on wire.Group {
  Group toModel() => Group(
    id: id,
    name: name,
    memberCount: memberCount,
    createdBy: createdBy?.toModel(),
    myRole: myRole == null || myRole == wire.GroupMyRole.swaggerGeneratedUnknown ? null : _role(myRole!.value),
  );

  ShareTarget toTarget() => _groupTarget(id: id, name: name, memberCount: memberCount);
}

extension GroupDetailsToModel on wire.GroupDetails {
  GroupDetails toModel() => GroupDetails(
    group: group.toModel(),
    members: [
      for (final member in members ?? <wire.Member>[])
        GroupMember(user: member.user.toModel(), role: _role(member.role.value)),
    ],
    canManage: canManage,
  );
}

extension DirectoryResponseToModel on wire.DirectoryResponse {
  ShareTargets toModel() => ShareTargets(
    users: [for (final user in users ?? <wire.UserSummary>[]) user.toModel()],
    groups: [for (final group in groups ?? <wire.Group>[]) group.toTarget()],
  );
}

extension RecipientToModel on wire.Recipient {
  ShareTarget toModel() => kind.value == ShareTargetKind.group.name
      ? _groupTarget(id: id, name: name)
      : _userTarget(id: id, name: name, username: username, avatar: avatar);
}

extension FileSummaryToModel on wire.FileSummary {
  SharedFile toModel() => SharedFile(id: id, name: name, isDir: isDir);
}

extension ShareToModel on wire.Share {
  OutgoingShare toModel() => OutgoingShare(
    id: id,
    file: file.toModel(),
    owner: owner.toModel(),
    recipient: recipient.toModel(),
    permissions: permissions.toModel(),
    expiresAt: expiresAt,
    note: note,
    available: available,
    canChange: canChange,
    canRemove: canRemove,
  );
}

extension IncomingShareToModel on wire.IncomingShare {
  IncomingShare toModel() => IncomingShare(
    id: id,
    owner: owner.toModel(),
    direct: direct,
    groups: [for (final group in groups ?? const <wire.GroupRef>[]) _groupTarget(id: group.id, name: group.name)],
    permissions: permissions.toModel(),
    expiresAt: expiresAt,
    note: note,
    entry: entry.toModel(),
  );
}

extension ShareLinkToModel on wire.ShareLink {
  ShareLink toModel() => ShareLink(
    id: id,
    code: code,
    file: file.toModel(),
    permissions: permissions.toModel(),
    hasPassword: hasPassword,
    expiresAt: expiresAt,
    available: available,
  );
}

extension LinkInfoToModel on wire.LinkInfo {
  PublicLinkInfo toModel() => PublicLinkInfo(
    needsPassword: needsPassword,
    permissions: permissions.toModel(),
    name: name,
    owner: owner?.toModel(),
  );
}

extension LinkUnlockToModel on wire.LinkUnlock {
  PublicLinkUnlock toModel() =>
      PublicLinkUnlock(token: token, expiresAt: expiresAt, info: info.toModel(), root: root.toModel());
}

extension LinkMatchToModel on wire.LinkMatch {
  LinkMatch toModel() => LinkMatch(ownPath: ownPath, shareId: shareId, path: path);
}
