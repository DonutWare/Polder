import "package:polder_core/models/token_pair.dart";

class TwoFactorState {
  const TwoFactorState({
    required this.enabled,
    required this.recoveryCodesRemaining,
    required this.required,
    this.deadline,
  });

  final bool enabled;
  final int recoveryCodesRemaining;
  final bool required;
  final DateTime? deadline;
}

class TwoFactorSetup {
  const TwoFactorSetup({required this.secret, required this.url});

  final String secret;
  final String url;

  String get groupedSecret => [
    for (var start = 0; start < secret.length; start += 4) secret.substring(start, (start + 4).clamp(0, secret.length)),
  ].join(" ");
}

class LinkedIdentity {
  const LinkedIdentity({
    required this.id,
    required this.providerId,
    required this.providerLabel,
    required this.preset,
    required this.email,
    required this.createdAt,
  });

  final int id;
  final String providerId;
  final String providerLabel;
  final String preset;
  final String email;
  final DateTime createdAt;
}

enum AuthProviderField { serverUrl, realm, slug, tenantId, issuer }

class AuthProviderPreset {
  const AuthProviderPreset({
    required this.id,
    required this.label,
    required this.fields,
    required this.allowSignup,
    required this.linkByEmail,
    required this.isPublic,
    required this.setupHint,
    required this.scopes,
    required this.usernameClaim,
  });

  final String id;
  final String label;
  final List<AuthProviderField> fields;
  final bool allowSignup;
  final bool linkByEmail;
  final bool isPublic;
  final String setupHint;
  final String scopes;
  final String usernameClaim;
}

class AuthProvider {
  const AuthProvider({
    required this.id,
    required this.preset,
    required this.label,
    required this.issuer,
    required this.clientId,
    required this.clientSecretSet,
    required this.scopes,
    required this.usernameClaim,
    required this.allowSignup,
    required this.linkByEmail,
    required this.enabled,
    required this.managedByConfig,
    required this.callbackUrl,
    required this.linkedUsers,
    required this.isGitHub,
  });

  final String id;
  final String preset;
  final String label;
  final String issuer;
  final String clientId;
  final bool clientSecretSet;
  final String scopes;
  final String usernameClaim;
  final bool allowSignup;
  final bool linkByEmail;
  final bool enabled;
  final bool managedByConfig;
  final String callbackUrl;
  final int linkedUsers;
  final bool isGitHub;
}

class NewAuthProvider {
  const NewAuthProvider({
    required this.preset,
    required this.clientId,
    required this.clientSecret,
    required this.allowSignup,
    required this.linkByEmail,
    this.label = "",
    this.fields = const {},
  });

  final String preset;
  final String label;
  final Map<AuthProviderField, String> fields;
  final String clientId;
  final String clientSecret;
  final bool allowSignup;
  final bool linkByEmail;
}

class AuthProviderChanges {
  const AuthProviderChanges({
    this.label,
    this.issuer,
    this.clientId,
    this.clientSecret,
    this.allowSignup,
    this.linkByEmail,
    this.enabled,
  });

  final String? label;
  final String? issuer;
  final String? clientId;
  final String? clientSecret;
  final bool? allowSignup;
  final bool? linkByEmail;
  final bool? enabled;
}

class LoginRequest {
  const LoginRequest({
    required this.id,
    required this.device,
    required this.address,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String device;
  final String address;
  final DateTime createdAt;
  final DateTime expiresAt;
}

class DeviceLoginStart {
  const DeviceLoginStart({
    required this.requestId,
    required this.pollToken,
    required this.number,
    required this.expiresIn,
  });

  final String requestId;
  final String pollToken;
  final int number;
  final Duration expiresIn;
}

enum DeviceLoginStatus { pending, approved, denied, expired, cancelled }

class DeviceLoginResult {
  const DeviceLoginResult({required this.status, this.tokens});

  final DeviceLoginStatus status;
  final TokenPair? tokens;
}
