import "package:flutter/widgets.dart";

import "package:polder_core/models/security.dart";
import "package:polder_ui/util/localization_helper.dart";

class ProviderTerms {
  const ProviderTerms({
    required this.providerName,
    required this.serverUrl,
    required this.clientId,
    required this.clientSecret,
    required this.redirectField,
    this.slug,
    this.realm,
    this.tenantId,
    this.tenantIdHint,
  });

  factory ProviderTerms.of(BuildContext context, String preset) {
    final localized = context.localized;
    ProviderTerms named(String name, {required String redirectField, String? slug, String? realm}) => ProviderTerms(
      providerName: name,
      serverUrl: localized.providerUrlNamed(name),
      clientId: localized.clientId,
      clientSecret: localized.clientSecret,
      redirectField: redirectField,
      slug: slug,
      realm: realm,
    );
    return switch (preset) {
      "pocket-id" => named("Pocket ID", redirectField: "Callback URLs"),
      "authentik" => named("authentik", redirectField: "Redirect URIs", slug: localized.providerSlug),
      "authelia" => const ProviderTerms(
        providerName: "Authelia",
        serverUrl: "Authelia URL",
        clientId: "client_id",
        clientSecret: "client_secret",
        redirectField: "redirect_uris",
      ),
      "keycloak" => named("Keycloak", redirectField: "Valid redirect URIs", realm: localized.providerRealm),
      "google" => named("Google", redirectField: "Authorized redirect URIs"),
      "microsoft" => ProviderTerms(
        providerName: "Microsoft Entra",
        serverUrl: localized.providerServerUrl,
        clientId: "Application (client) ID",
        clientSecret: "Client secret value",
        redirectField: "Redirect URI (Web)",
        tenantId: "Directory (tenant) ID",
        tenantIdHint: localized.providerTenantIdHint,
      ),
      "github" => named("GitHub", redirectField: "Authorization callback URL"),
      _ => ProviderTerms(
        providerName: localized.identityProvider,
        serverUrl: localized.issuerUrl,
        clientId: localized.clientId,
        clientSecret: localized.clientSecret,
        redirectField: "Redirect URI",
      ),
    };
  }

  final String providerName;
  final String serverUrl;
  final String clientId;
  final String clientSecret;
  final String redirectField;
  final String? slug;
  final String? realm;
  final String? tenantId;
  final String? tenantIdHint;

  String fieldLabel(BuildContext context, AuthProviderField field) => switch (field) {
    AuthProviderField.serverUrl => serverUrl,
    AuthProviderField.realm => realm ?? context.localized.providerRealm,
    AuthProviderField.slug => slug ?? context.localized.providerSlug,
    AuthProviderField.tenantId => tenantId ?? context.localized.providerTenantId,
    AuthProviderField.issuer => context.localized.issuerUrl,
  };

  String? fieldHint(AuthProviderField field) => field == AuthProviderField.tenantId ? tenantIdHint : null;
}
