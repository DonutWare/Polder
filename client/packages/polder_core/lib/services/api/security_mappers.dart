import "package:polder_core/models/security.dart";
import "package:polder_core/services/api/generated/polder.swagger.dart" as wire;
import "package:polder_core/services/api/wire_mappers.dart";

extension TwoFactorSettingsToModel on wire.TwoFactorSettings {
  TwoFactorState toModel() => TwoFactorState(
    enabled: enabled,
    recoveryCodesRemaining: recoveryCodesRemaining,
    required: required,
    deadline: deadline,
  );
}

extension TwoFactorSetupToModel on wire.TwoFactorSetup {
  TwoFactorSetup toModel() => TwoFactorSetup(secret: secret, url: url);
}

extension LinkedIdentityToModel on wire.LinkedIdentity {
  LinkedIdentity toModel() => LinkedIdentity(
    id: id,
    providerId: providerId,
    providerLabel: providerLabel,
    preset: preset,
    email: email,
    createdAt: createdAt,
  );
}

extension AuthProviderPresetToModel on wire.AuthProviderPreset {
  AuthProviderPreset toModel() => AuthProviderPreset(
    id: id,
    label: label,
    fields: [
      for (final field in fields ?? const <wire.AuthProviderPresetFields>[])
        ?AuthProviderField.values.asNameMap()[field.value],
    ],
    allowSignup: allowSignup,
    linkByEmail: linkByEmail,
    isPublic: public,
    setupHint: setupHint,
    scopes: scopes,
    usernameClaim: usernameClaim,
  );
}

extension AuthProviderToModel on wire.AuthProvider {
  AuthProvider toModel() => AuthProvider(
    id: id,
    preset: preset,
    label: label,
    issuer: issuer,
    clientId: clientId,
    clientSecretSet: clientSecretSet,
    scopes: scopes,
    usernameClaim: usernameClaim,
    allowSignup: allowSignup,
    linkByEmail: linkByEmail,
    enabled: enabled,
    managedByConfig: managedByConfig,
    callbackUrl: callbackUrl,
    linkedUsers: linkedUsers,
    isGitHub: kind == wire.AuthProviderKind.github,
  );
}

extension NewAuthProviderToWire on NewAuthProvider {
  wire.NewAuthProvider toWire() => wire.NewAuthProvider(
    preset: preset,
    label: label.trim().isEmpty ? null : label.trim(),
    serverUrl: fields[AuthProviderField.serverUrl],
    realm: fields[AuthProviderField.realm],
    slug: fields[AuthProviderField.slug],
    tenantId: fields[AuthProviderField.tenantId],
    issuer: fields[AuthProviderField.issuer],
    clientId: clientId.trim(),
    clientSecret: clientSecret,
    allowSignup: allowSignup,
    linkByEmail: linkByEmail,
  );
}

extension AuthProviderChangesToWire on AuthProviderChanges {
  wire.AuthProviderChanges toWire() => wire.AuthProviderChanges(
    label: label,
    issuer: issuer,
    clientId: clientId,
    clientSecret: clientSecret,
    allowSignup: allowSignup,
    linkByEmail: linkByEmail,
    enabled: enabled,
  );
}

extension LoginRequestToModel on wire.LoginRequest {
  LoginRequest toModel() =>
      LoginRequest(id: id, device: device, address: address, createdAt: createdAt, expiresAt: expiresAt);
}

extension DeviceLoginStartToModel on wire.DeviceLoginStart {
  DeviceLoginStart toModel() => DeviceLoginStart(
    requestId: requestId,
    pollToken: pollToken,
    number: number,
    expiresIn: Duration(seconds: expiresIn),
  );
}

extension DeviceLoginResultToModel on wire.DeviceLoginResult {
  DeviceLoginResult toModel() => DeviceLoginResult(
    status: DeviceLoginStatus.values.asNameMap()[status.value] ?? DeviceLoginStatus.expired,
    tokens: tokens?.toModel(),
  );
}
