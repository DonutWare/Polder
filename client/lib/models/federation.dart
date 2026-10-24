import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/sharing.dart";

part "federation.freezed.dart";

@freezed
abstract class AppPassword with _$AppPassword {
  const factory AppPassword({
    required int id,
    required String name,
    required bool readOnly,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    @Default("") String lastUsedAddress,
  }) = _AppPassword;
}

@freezed
abstract class CreatedAppPassword with _$CreatedAppPassword {
  const factory CreatedAppPassword({required AppPassword password, required String token}) = _CreatedAppPassword;
}

@freezed
abstract class FederationStatus with _$FederationStatus {
  const factory FederationStatus({
    @Default(false) bool enabled,
    @Default(false) bool configured,
    @Default("") String cloudId,
  }) = _FederationStatus;
}

@freezed
abstract class TrustedServer with _$TrustedServer {
  const factory TrustedServer({
    required int id,
    required String remote,
    @Default("") String provider,
    @Default("") String keyFingerprint,
    @Default(false) bool allowPrivateNetwork,
    @Default(true) bool verifySenderAddress,
    @Default(false) bool signsRequests,
    @Default("") String apiVersion,
    required DateTime createdAt,
    DateTime? discoveredAt,
  }) = _TrustedServer;
}

@freezed
abstract class FederationInvite with _$FederationInvite {
  const factory FederationInvite({
    required int id,
    @Default("") String token,
    required String provider,
    required DateTime expiresAt,
  }) = _FederationInvite;
}

@freezed
abstract class FederationContact with _$FederationContact {
  const FederationContact._();

  const factory FederationContact({
    required int id,
    required String cloudId,
    @Default("") String name,
    @Default("") String email,
    @Default("") String server,
  }) = _FederationContact;

  String get shownName => name.isEmpty ? cloudId : name;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return cloudId.toLowerCase().contains(lower) ||
        name.toLowerCase().contains(lower) ||
        email.toLowerCase().contains(lower);
  }
}

enum FederatedShareState { pending, accepted }

@freezed
abstract class FederatedShare with _$FederatedShare {
  const FederatedShare._();

  const factory FederatedShare({
    required int id,
    required SharedFile file,
    required String recipient,
    @Default("") String recipientName,
    required SharePermissions permissions,
    DateTime? expiresAt,
    required FederatedShareState state,
    @Default(true) bool available,
  }) = _FederatedShare;

  bool get isPending => state == FederatedShareState.pending;
}

@freezed
abstract class IncomingFederatedShare with _$IncomingFederatedShare {
  const IncomingFederatedShare._();

  const factory IncomingFederatedShare({
    required int id,
    required String name,
    required String owner,
    @Default("") String ownerName,
    @Default("") String server,
    @Default("") String provider,
    @Default(true) bool isDir,
    required SharePermissions permissions,
    required FederatedShareState state,
    @Default("") String mountPath,
  }) = _IncomingFederatedShare;

  bool get isPending => state == FederatedShareState.pending;

  String get shownOwner => ownerName.isEmpty ? owner : "$ownerName ($owner)";
}

final _cloudIdPattern = RegExp(r"^[^@\s/]+(@[^@\s/]+)*@[A-Za-z0-9.-]+(:[0-9]{1,5})?(/[A-Za-z0-9._~-]+)*$");

bool looksLikeCloudId(String value) => _cloudIdPattern.hasMatch(value.trim());
