import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/federation.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/guarded_refresh.dart";

final federationStatusProvider = FutureProvider.autoDispose<FederationStatus>(
  (ref) => ref.watch(polderApiProvider).federationStatus(),
);

final appPasswordsProvider = AsyncNotifierProvider.autoDispose<AppPasswordsNotifier, List<AppPassword>>(
  AppPasswordsNotifier.new,
);

class AppPasswordsNotifier extends AsyncNotifier<List<AppPassword>> with GuardedRefresh {
  @override
  Future<List<AppPassword>> build() => ref.watch(polderApiProvider).appPasswords();

  Future<void> refresh() => refreshWith(() => ref.read(polderApiProvider).appPasswords());

  Future<CreatedAppPassword> create({
    required String name,
    required String currentPassword,
    bool readOnly = false,
  }) async {
    final created = await ref
        .read(polderApiProvider)
        .createAppPassword(name: name, currentPassword: currentPassword, readOnly: readOnly);
    state = AsyncData([created.password, ...?state.value]);
    return created;
  }

  Future<void> revoke(AppPassword password) async {
    await ref.read(polderApiProvider).deleteAppPassword(password.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != password.id)]);
  }
}

final trustedServersProvider = AsyncNotifierProvider.autoDispose<TrustedServersNotifier, List<TrustedServer>>(
  TrustedServersNotifier.new,
);

class TrustedServersNotifier extends AsyncNotifier<List<TrustedServer>> with GuardedRefresh {
  @override
  Future<List<TrustedServer>> build() => ref.watch(polderApiProvider).trustedServers();

  Future<void> refresh() => refreshWith(() => ref.read(polderApiProvider).trustedServers());

  Future<void> add(String remote, {bool allowPrivateNetwork = false, bool skipAddressCheck = false}) async {
    final added = await ref
        .read(polderApiProvider)
        .addTrustedServer(remote, allowPrivateNetwork: allowPrivateNetwork, skipAddressCheck: skipAddressCheck);
    state = AsyncData([...?state.value, added]..sort((a, b) => a.remote.compareTo(b.remote)));
  }

  Future<void> rediscover(TrustedServer server) async {
    final refreshed = await ref.read(polderApiProvider).refreshTrustedServer(server.id);
    state = AsyncData([
      for (final existing in state.value ?? <TrustedServer>[]) existing.id == server.id ? refreshed : existing,
    ]);
  }

  Future<void> setAddressCheck(TrustedServer server, {required bool verify}) async {
    final updated = await ref
        .read(polderApiProvider)
        .updateTrustedServer(server.id, allowPrivateNetwork: server.allowPrivateNetwork, skipAddressCheck: !verify);
    state = AsyncData([
      for (final existing in state.value ?? <TrustedServer>[]) existing.id == server.id ? updated : existing,
    ]);
  }

  Future<void> remove(TrustedServer server) async {
    await ref.read(polderApiProvider).removeTrustedServer(server.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != server.id)]);
  }
}

final federatedSharesProvider = AsyncNotifierProvider.autoDispose
    .family<FederatedSharesNotifier, List<FederatedShare>, int?>(FederatedSharesNotifier.new);

class FederatedSharesNotifier extends AsyncNotifier<List<FederatedShare>> with GuardedRefresh {
  FederatedSharesNotifier(this.fileId);

  final int? fileId;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<FederatedShare>> build() => ref.watch(polderApiProvider).federatedShares(fileId: fileId);

  Future<void> refresh() => refreshWith(() => _api.federatedShares(fileId: fileId));

  Future<void> add({required int fileId, required String recipient, required SharePermissions permissions}) async {
    final created = await _api.shareFederated(fileId: fileId, recipient: recipient, permissions: permissions);
    state = AsyncData([created, ...?state.value]);
    _invalidateOthers();
  }

  Future<void> change(FederatedShare share, SharePermissions permissions) async {
    final updated = await _api.updateFederatedShare(share.id, permissions: permissions);
    state = AsyncData([
      for (final existing in state.value ?? <FederatedShare>[]) existing.id == share.id ? updated : existing,
    ]);
    _invalidateOthers();
  }

  Future<void> remove(FederatedShare share) async {
    await _api.removeFederatedShare(share.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != share.id)]);
    _invalidateOthers();
  }

  void _invalidateOthers() {
    if (fileId != null) ref.invalidate(federatedSharesProvider(null));
  }
}

final incomingFederatedSharesProvider =
    AsyncNotifierProvider.autoDispose<IncomingFederatedSharesNotifier, List<IncomingFederatedShare>>(
      IncomingFederatedSharesNotifier.new,
    );

class IncomingFederatedSharesNotifier extends AsyncNotifier<List<IncomingFederatedShare>> with GuardedRefresh {
  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<IncomingFederatedShare>> build() => ref.watch(polderApiProvider).incomingFederatedShares();

  Future<void> refresh() => refreshWith(() => _api.incomingFederatedShares());

  Future<void> accept(IncomingFederatedShare share) async {
    final accepted = await _api.acceptFederatedShare(share.id);
    state = AsyncData([
      for (final existing in state.value ?? <IncomingFederatedShare>[]) existing.id == share.id ? accepted : existing,
    ]);
  }

  Future<void> remove(IncomingFederatedShare share) async {
    await _api.removeIncomingFederatedShare(share.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != share.id)]);
  }
}

final incomingFederatedShareProvider = Provider.autoDispose.family<IncomingFederatedShare?, int>(
  (ref, shareId) => ref.watch(incomingFederatedSharesProvider).value?.where((share) => share.id == shareId).firstOrNull,
);

final federationContactsProvider =
    AsyncNotifierProvider.autoDispose<FederationContactsNotifier, List<FederationContact>>(
      FederationContactsNotifier.new,
    );

class FederationContactsNotifier extends AsyncNotifier<List<FederationContact>> with GuardedRefresh {
  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<FederationContact>> build() => ref.watch(polderApiProvider).federationContacts();

  Future<void> refresh() => refreshWith(() => _api.federationContacts());

  Future<FederationContact> acceptInvite({required String token, required String provider}) async {
    final contact = await _api.acceptFederationInvite(token: token, provider: provider);
    state = AsyncData([...?state.value, contact]);
    return contact;
  }

  Future<void> remove(FederationContact contact) async {
    await _api.removeFederationContact(contact.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != contact.id)]);
  }
}

final federationInvitesProvider = AsyncNotifierProvider.autoDispose<FederationInvitesNotifier, List<FederationInvite>>(
  FederationInvitesNotifier.new,
);

class FederationInvitesNotifier extends AsyncNotifier<List<FederationInvite>> with GuardedRefresh {
  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<FederationInvite>> build() => ref.watch(polderApiProvider).federationInvites();

  Future<FederationInvite> create() async {
    final invite = await _api.createFederationInvite();
    state = AsyncData([invite, ...?state.value]);
    return invite;
  }

  Future<void> revoke(FederationInvite invite) async {
    await _api.revokeFederationInvite(invite.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != invite.id)]);
  }
}
