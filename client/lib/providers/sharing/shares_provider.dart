import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/guarded_refresh.dart";

void invalidateShares(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(incomingSharesProvider);
  invalidate(outgoingSharesProvider);
  invalidate(groupSharesProvider);
}

final incomingSharesProvider = AsyncNotifierProvider.autoDispose<IncomingSharesNotifier, List<IncomingShare>>(
  IncomingSharesNotifier.new,
);

class IncomingSharesNotifier extends AsyncNotifier<List<IncomingShare>> with GuardedRefresh {
  @override
  Future<List<IncomingShare>> build() => _fetch(ref.watch(polderApiProvider));

  Future<void> refresh() => refreshWith(() => _fetch(ref.read(polderApiProvider)));

  Future<List<IncomingShare>> _fetch(PolderApi api) => api.incomingShares();

  Future<void> leave(IncomingShare share) async {
    await ref.read(polderApiProvider).removeShare(share.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != share.id)]);
    invalidateShares(ref.invalidate);
  }
}

final incomingShareProvider = Provider.autoDispose.family<IncomingShare?, int>(
  (ref, shareId) => ref.watch(incomingSharesProvider).value?.where((share) => share.id == shareId).firstOrNull,
);

final outgoingSharesProvider = AsyncNotifierProvider.autoDispose
    .family<OutgoingSharesNotifier, List<OutgoingShare>, int?>(OutgoingSharesNotifier.new);

class OutgoingSharesNotifier extends AsyncNotifier<List<OutgoingShare>> with GuardedRefresh, _FileScoped {
  OutgoingSharesNotifier(this.fileId);

  @override
  final int? fileId;

  @override
  Future<List<OutgoingShare>> build() => _fetch(ref.watch(polderApiProvider));

  Future<void> refresh() => refreshWith(() => _fetch(_api));

  Future<List<OutgoingShare>> _fetch(PolderApi api) => api.outgoingShares(fileId: fileId);

  Future<void> add({
    required int fileId,
    required ShareTarget recipient,
    required SharePermissions permissions,
    DateTime? expiresAt,
    String note = "",
  }) async {
    final created = await _api.share(
      fileId: fileId,
      recipient: recipient,
      permissions: permissions,
      expiresAt: expiresAt,
      note: note,
    );
    state = AsyncData([created, ...?state.value]);
    _refreshAllFiles(outgoingSharesProvider(null));
  }
}

final shareLinksProvider = AsyncNotifierProvider.autoDispose.family<ShareLinksNotifier, List<ShareLink>, int?>(
  ShareLinksNotifier.new,
);

class ShareLinksNotifier extends AsyncNotifier<List<ShareLink>> with GuardedRefresh, _FileScoped {
  ShareLinksNotifier(this.fileId);

  @override
  final int? fileId;

  @override
  Future<List<ShareLink>> build() => _fetch(ref.watch(polderApiProvider));

  Future<void> refresh() => refreshWith(() => _fetch(_api));

  Future<List<ShareLink>> _fetch(PolderApi api) => api.shareLinks(fileId: fileId);

  Future<ShareLink> create(int fileId, LinkOptions options) async {
    final created = await _api.createShareLink(fileId, options);
    state = AsyncData([created, ...?state.value]);
    _refreshAllFiles(shareLinksProvider(null));
    return created;
  }

  Future<ShareLink> edit(ShareLink link, LinkOptions options) async {
    final updated = await _api.updateShareLink(link.id, options);
    state = AsyncData([
      for (final existing in state.value ?? <ShareLink>[]) existing.id == link.id ? updated : existing,
    ]);
    _refreshAllFiles(shareLinksProvider(null));
    return updated;
  }

  Future<void> remove(ShareLink link) async {
    await _api.deleteShareLink(link.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != link.id)]);
    _refreshAllFiles(shareLinksProvider(null));
  }
}

mixin _FileScoped<T> on AsyncNotifier<T> {
  int? get fileId;

  PolderApi get _api => ref.read(polderApiProvider);

  void _refreshAllFiles(ProviderOrFamily allFiles) {
    if (fileId != null) ref.invalidate(allFiles);
  }
}

final groupSharesProvider = AsyncNotifierProvider.autoDispose.family<GroupSharesNotifier, List<OutgoingShare>, int>(
  GroupSharesNotifier.new,
);

class GroupSharesNotifier extends AsyncNotifier<List<OutgoingShare>> {
  GroupSharesNotifier(this.groupId);

  final int groupId;

  @override
  Future<List<OutgoingShare>> build() => ref.watch(polderApiProvider).groupShares(groupId);
}

final shareTargetSearchProvider = FutureProvider.autoDispose.family<ShareTargets, String>((ref, query) async {
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (cancelled) return const ShareTargets();
  return ref.watch(polderApiProvider).searchShareTargets(query);
});
