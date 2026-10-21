import "package:polder/models/directory_listing.dart";
import "package:polder/models/federation.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/sharing_mappers.dart";

FederatedShareState _state(String? value) =>
    value == FederatedShareState.accepted.name ? FederatedShareState.accepted : FederatedShareState.pending;

extension AppPasswordToModel on wire.AppPassword {
  AppPassword toModel() => AppPassword(
    id: id,
    name: name,
    readOnly: readOnly,
    createdAt: createdAt.toLocal(),
    lastUsedAt: lastUsedAt?.toLocal(),
    lastUsedAddress: lastUsedAddress,
  );
}

extension NewAppPasswordToModel on wire.NewAppPassword {
  CreatedAppPassword toModel() => CreatedAppPassword(
    password: AppPassword(
      id: id,
      name: name,
      readOnly: readOnly,
      createdAt: createdAt.toLocal(),
      lastUsedAt: lastUsedAt?.toLocal(),
      lastUsedAddress: lastUsedAddress,
    ),
    token: token,
  );
}

extension FederationStatusToModel on wire.FederationStatus {
  FederationStatus toModel() => FederationStatus(enabled: enabled, configured: configured, cloudId: cloudId);
}

extension TrustedServerToModel on wire.Server {
  TrustedServer toModel() => TrustedServer(
    id: id,
    remote: remote,
    provider: provider,
    keyFingerprint: keyFingerprint,
    allowPrivateNetwork: allowPrivateNetwork,
    verifySenderAddress: verifySenderAddress,
    signsRequests: signsRequests,
    apiVersion: apiVersion,
    createdAt: createdAt.toLocal(),
    discoveredAt: discoveredAt?.toLocal(),
  );
}

extension FederatedShareToModel on wire.OutgoingShare {
  FederatedShare toModel() => FederatedShare(
    id: id,
    file: file.toModel(),
    recipient: recipient,
    recipientName: recipientName,
    permissions: permissions.toModel(),
    expiresAt: expiresAt?.toLocal(),
    state: _state(state.value),
    available: available,
  );
}

extension IncomingFederatedShareToModel on wire.IncomingFederatedShare {
  IncomingFederatedShare toModel() => IncomingFederatedShare(
    id: id,
    name: name,
    owner: owner,
    ownerName: ownerName,
    server: server,
    provider: provider,
    isDir: isDir,
    permissions: permissions.toModel(),
    state: _state(state.value),
  );
}

extension RemoteEntryToModel on wire.RemoteEntry {
  FileEntry toModel() =>
      FileEntry(path: path, name: name, isDir: isDir, size: size, mtime: mtime.toLocal(), hash: etag, mime: mime);
}

extension RemoteListResponseToModel on wire.RemoteListResponse {
  DirectoryListing toModel() => DirectoryListing(
    path: item.path,
    entries: [for (final entry in entries ?? <wire.RemoteEntry>[]) entry.toModel()],
  );
}

extension InviteToModel on wire.Invite {
  FederationInvite toModel() =>
      FederationInvite(id: id, token: token ?? "", provider: provider, expiresAt: expiresAt.toLocal());
}

extension ContactToModel on wire.Contact {
  FederationContact toModel() => FederationContact(id: id, cloudId: cloudId, name: name, email: email, server: server);
}
