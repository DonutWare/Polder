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
needs an SMTP server.

| Setting | Environment variable | Meaning |
| --- | --- | --- |
| `calendarMaxEventBytes` | `POLDER_CALENDAR_MAX_EVENT_BYTES` | Largest event apps may store, in bytes (default 1 MiB) |
| `calendarSubscriptionMinRefresh` | `POLDER_CALENDAR_SUBSCRIPTION_MIN_REFRESH` | Shortest time between refreshes of a subscribed feed (default `15m`) |
| `calendarSubscriptionsAllowPrivate` | `POLDER_CALENDAR_SUBSCRIPTIONS_ALLOW_PRIVATE` | Allow subscribing to feeds on private networks, such as other services on the same LAN |
| `smtpHost` | `POLDER_SMTP_HOST` | Mail server for invitations to people outside Polder |
| `smtpPort` | `POLDER_SMTP_PORT` | Mail server port (default 587, or 465 with `tls`) |
| `smtpUsername` | `POLDER_SMTP_USERNAME` | Mail server login |
| `smtpPassword` | `POLDER_SMTP_PASSWORD` | Mail server password |
| `smtpFrom` | `POLDER_SMTP_FROM` | Sender address, such as `Polder <calendar@example.com>` |
| `smtpSecurity` | `POLDER_SMTP_SECURITY` | `starttls` (default), `tls` or `none` |

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
