import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/sharing.dart";

part "group.freezed.dart";

enum GroupRole { admin, member, viewer }

enum GroupScope { mine, all }

@freezed
abstract class Group with _$Group {
  const factory Group({
    required int id,
    required String name,
    @Default(0) int memberCount,
    ShareTarget? createdBy,
    GroupRole? myRole,
  }) = _Group;
}

@freezed
abstract class GroupMember with _$GroupMember {
  const factory GroupMember({required ShareTarget user, required GroupRole role}) = _GroupMember;
}

@freezed
abstract class GroupDetails with _$GroupDetails {
  const GroupDetails._();

  const factory GroupDetails({
    required Group group,
    @Default(<GroupMember>[]) List<GroupMember> members,
    @Default(false) bool canManage,
  }) = _GroupDetails;

  int get adminCount => members.where((member) => member.role == GroupRole.admin).length;
}
