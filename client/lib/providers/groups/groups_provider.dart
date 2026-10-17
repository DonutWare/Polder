import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/services/api/polder_api.dart";

final groupsProvider = AsyncNotifierProvider.autoDispose.family<GroupsNotifier, List<Group>, GroupScope>(
  GroupsNotifier.new,
);

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  GroupsNotifier(this.scope);

  final GroupScope scope;

  @override
  Future<List<Group>> build() => ref.watch(polderApiProvider).groups(scope: scope);

  Future<Group> create(String name) async {
    final created = await ref.read(polderApiProvider).createGroup(name);
    ref.invalidateSelf();
    _refreshAll(ref, except: scope);
    return created;
  }
}

void _refreshAll(Ref ref, {GroupScope? except}) {
  for (final scope in GroupScope.values) {
    if (scope != except) ref.invalidate(groupsProvider(scope));
  }
}

final groupProvider = AsyncNotifierProvider.autoDispose.family<GroupNotifier, GroupDetails, int>(GroupNotifier.new);

class GroupNotifier extends AsyncNotifier<GroupDetails> {
  GroupNotifier(this.groupId);

  final int groupId;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<GroupDetails> build() => ref.watch(polderApiProvider).group(groupId);

  Future<void> rename(String name) async {
    await _api.renameGroup(groupId, name);
    ref.invalidateSelf();
    _refreshAll(ref);
  }

  Future<void> delete() async {
    await _api.deleteGroup(groupId);
    _refreshAll(ref);
    invalidateShares(ref.invalidate);
  }

  Future<void> addMember(ShareTarget user, GroupRole role) => _apply(() => _api.addGroupMember(groupId, user.id, role));

  Future<void> setRole(GroupMember member, GroupRole role) =>
      _apply(() => _api.setGroupMemberRole(groupId, member.user.id, role));

  Future<void> removeMember(GroupMember member) async {
    await _api.removeGroupMember(groupId, member.user.id);
    ref.invalidateSelf();
    _refreshAll(ref);
    invalidateShares(ref.invalidate);
  }

  Future<void> leave(int myId) async {
    await _api.removeGroupMember(groupId, myId);
    _refreshAll(ref);
    invalidateShares(ref.invalidate);
  }

  Future<void> _apply(Future<GroupDetails> Function() change) async {
    state = AsyncData(await change());
    _refreshAll(ref);
  }
}
