# Polder server

The self-hosted Polder backend, written in Go. It provides the API, file
storage, sync, authentication, search, and the optional Flutter web app.

## Requirements

- Go 1.27+
- Flutter, for the client or web app
- Docker, for Docker and document editor (Collabora Online or Euro-Office) workflows

## Run

The simplest local run uses the repository's `config/` and `data/` directories:

```sh
mkdir -p config data
POLDER_CONFIG_DIR=./config POLDER_DATA_DIR=./data go run ./cmd/polder
```

For the full web app in Docker:

```sh
mkdir -p config data
POLDER_UID=$(id -u) POLDER_GID=$(id -g) docker compose up -d --build
```

The server listens on `http://localhost:6060` by default. Check it with:

```sh
curl http://localhost:6060/healthz
```

## Document editor

Documents can be edited in the apps through an optional editor that speaks
WOPI: [Collabora Online](https://www.collaboraonline.com/code/) or
[Euro-Office](https://github.com/Euro-Office/DocumentServer). Set up at most
one of them. Without either, documents still open as previews. Clients only
talk to Polder, which proxies the editor (Euro-Office under `/eurooffice/`). The
editor also draws thumbnails of documents that don't include one.

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `collaboraUrl` | `POLDER_COLLABORA_URL` | Where Polder reaches Collabora Online |
| `euroOfficeUrl` | `POLDER_EURO_OFFICE_URL` | Where Polder reaches Euro-Office |
| `wopiUrl` | `POLDER_WOPI_URL` | Where the editor reaches Polder |

With Docker Compose, start the editor's profile next to Polder.

Collabora Online:

```sh
POLDER_COLLABORA_URL=http://collabora:9980 \
  docker compose --profile office up -d
```

Euro-Office:

```sh
POLDER_EURO_OFFICE_URL=http://eurooffice \
EURO_OFFICE_JWT_SECRET=$(openssl rand -hex 32) \
  docker compose --profile eurooffice up -d
```

If you run Euro-Office yourself, start `ghcr.io/euro-office/documentserver` with
`WOPI_ENABLED=true`, because WOPI is off by default. If it reaches Polder at a
private address, also set `ALLOW_PRIVATE_IP_ADDRESS=true`. Euro-Office saves a
document back to Polder only after everyone has closed it.

Euro-Office has two other limits. It doesn't read Polder's colour palette,
so it only follows light or dark mode. A version restore made while a document
is open discards that session's unsaved edits.

## WebDAV

Files are available over WebDAV at `https://<server>/dav/files/<username>/`.
Log in with an app password, created under account settings. The account
password does not work for WebDAV. WebDAV requires HTTPS, either from
Polder itself or from a reverse proxy listed in `trustedProxies`.

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `webdavAllowInsecure` | `POLDER_WEBDAV_ALLOW_INSECURE` | Accept app passwords over plain HTTP, for testing only |

## Calendar

Calendars sync over CalDAV with app passwords and can be published as secret
subscription links. Users find their CalDAV addresses and manage subscription
links under account settings in the app. CalDAV has the same HTTPS
requirement as WebDAV. Set `publicUrl` so subscription links and invitation
emails carry the server's address.

Apps may log in with the email address from the user's profile instead of the
username. For calendar apps that set themselves up from an email address
alone, the email's domain needs DNS records pointing at Polder:

```
_caldavs._tcp.example.com. SRV 0 1 443 files.example.com.
_caldavs._tcp.example.com. TXT "path=/dav/"
```

Invitations to people with a Polder account are matched by the email address
in their profile. Other attendees get an email with an answer link, which
needs a [mail server](#email).

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `calendarMaxEventBytes` | `POLDER_CALENDAR_MAX_EVENT_BYTES` | Largest event apps may store, in bytes (default 1 MiB) |
| `calendarSubscriptionMinRefresh` | `POLDER_CALENDAR_SUBSCRIPTION_MIN_REFRESH` | Shortest time between refreshes of a subscribed feed (default `15m`) |
| `calendarSubscriptionsAllowPrivate` | `POLDER_CALENDAR_SUBSCRIPTIONS_ALLOW_PRIVATE` | Allow subscribing to feeds on private networks, such as other services on the same LAN |
## Email

With a mail server set, Polder sends email. Each one uses the server's name,
accent color and icon from the admin's branding settings.

| Email | Sent when | Can users turn it off? |
| --- | --- | --- |
| Password reset | "Forgot password?" on the sign-in screen; the link works once, for an hour | No |
| Password changed | The user, an admin or a reset changed the password | No |
| Welcome | An admin creates an account with an email address | No |
| New sign-in | An account signs in from an IP address it hasn't used before | Yes (security) |
| Email address changed | Sent to the old address | Yes (security) |
| Storage warning | Use passes 80%, 95% and 100% of the quota; it's sent again after use drops back below | Yes (storage) |
| Share received | Someone shares a file or folder, also from another server | Yes (sharing) |
| Two-factor required / reminder | 2FA becomes required, and again shortly before the deadline | No |
| Two-factor changed | 2FA turned on (security, optional), turned off or reset, or a recovery code was used | Mostly no |

Users choose which emails they get in Settings → Notifications. Emails go to
the address in their profile; accounts without one get none.

Admins set the mail server in Admin → Email, and can send a test email
from there. Setting `smtpHost` in the config or environment overrides the
admin settings, which then show the configured values read-only.

Password reset needs `publicUrl`, because the link in the email is built
from it. It is never built from the request's Host header, so a forged
request can't send a link to another site.

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `smtpHost` | `POLDER_SMTP_HOST` | Mail server; setting it locks the mail settings in the admin UI |
| `smtpPort` | `POLDER_SMTP_PORT` | Mail server port (default 587, or 465 with `tls`) |
| `smtpUsername` | `POLDER_SMTP_USERNAME` | Mail server login |
| `smtpPassword` | `POLDER_SMTP_PASSWORD` | Mail server password |
| `smtpFrom` | `POLDER_SMTP_FROM` | Sender address, such as `Polder <polder@example.com>` |
| `smtpSecurity` | `POLDER_SMTP_SECURITY` | `starttls` (default), `tls` or `none` |

## Signing in

- **Two-factor (TOTP)**: users enable it under account settings and get recovery codes. Admins can require it with a grace period in days; after the deadline, password sessions and app passwords are limited to setting it up. Reminders go out from an hourly job.
- **Quick login**: a signed-in device approves a new sign-in by typing the number the new device shows. It works passwordless or instead of the TOTP code, and is delivered over `/events`.
- **Single sign-on**: OIDC providers (with presets) and GitHub are configured in the admin UI. This needs `publicUrl`; the callback is `<publicUrl>/api/v1/auth/sso/<id>/callback`. SSO sessions are exempt from the 2FA requirement. Accounts without a password need a sign-in from the last 10 minutes to set a password, create app passwords or change two-factor settings. One provider can also come from the config:

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `ssoPreset` | `POLDER_SSO_PRESET` | `pocket-id`, `authentik`, `authelia`, `keycloak`, `google`, `microsoft`, `github` or `oidc` |
| `ssoLabel` | `POLDER_SSO_LABEL` | Text on the sign-in button; the preset's name by default |
| `ssoServerUrl` | `POLDER_SSO_SERVER_URL` | Where a self-hosted provider runs |
| `ssoRealm` | `POLDER_SSO_REALM` | Keycloak realm |
| `ssoSlug` | `POLDER_SSO_SLUG` | Authentik application slug |
| `ssoTenantId` | `POLDER_SSO_TENANT_ID` | Microsoft Entra tenant ID |
| `ssoIssuer` | `POLDER_SSO_ISSUER` | Issuer URL, for `oidc` |
| `ssoClientId` | `POLDER_SSO_CLIENT_ID` | Client ID registered at the provider |
| `ssoClientSecret` | `POLDER_SSO_CLIENT_SECRET` | Client secret |
| `ssoAllowSignup` | `POLDER_SSO_ALLOW_SIGNUP` | Create accounts on a first sign-in |
| `ssoLinkByEmail` | `POLDER_SSO_LINK_BY_EMAIL` | Match existing accounts by verified email address; never administrators, accounts with two-factor authentication, or addresses shared by several accounts. Off by default for Google, Microsoft and GitHub |

## Federation

Polder shares with other servers using
[Open Cloud Mesh](https://github.com/cs3org/OCM-API). To turn it on:

1. Set `publicUrl` to the server's https address.
2. Turn on federation in the admin settings.
3. Add the servers to trust.

Keep `<config>/federation.key`. It is the key Polder signs its requests
with.

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `publicUrl` | `POLDER_PUBLIC_URL` | The https address of this server, such as `https://files.example.com` |

## Development

Use the launch configurations in `.vscode/launch.json` for the server, the
server with the web app, focused tests, or the server and client together.

Useful tasks from the repository root:

```sh
go test ./...
golangci-lint run ./...
scripts/build-web.sh
scripts/gen-client.sh
scripts/test-client.sh
scripts/dev-office.sh             # server + Collabora Online in Docker
scripts/dev-office.sh eurooffice  # server + Euro-Office in Docker
```

To test federation against Nextcloud, see [dev/nextcloud](../dev/nextcloud/README.md).

The launch configurations `Server (Collabora)` and `Server (Euro-Office)` start
the editor in Docker and then debug the server against it.

After changing the API, run `scripts/gen-client.sh` and commit the updated
OpenAPI document and generated client code. See [client/README.md](../client/README.md)
for Flutter setup and client-specific commands.
