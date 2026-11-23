# Single sign-on providers

Real identity providers in Docker for trying and testing Polder's single sign-on:
Keycloak, Authelia, Pocket ID and authentik. Polder runs from this checkout on
`http://localhost:6060`, the address every provider has as its callback.

## Start

```sh
sh dev/sso/start.sh
```

It starts the containers and creates the users and the Polder client in each
provider. Running it again is safe. authentik takes about a minute on the first
start.

Authelia only speaks https, with a certificate made on the first start. The
script prints the command that makes this Mac trust it; Polder needs that to
reach Authelia. Your browser still warns about it once.

In VS Code, run **Server (SSO)** or **Server (SSO) + Client**. They start the
containers and run Polder with `publicUrl` set to `http://localhost:6060`.

## Users

Every provider has the same two users:

| User | Password | Email |
| --- | --- | --- |
| `alice` | `alice-password` | alice@example.com, verified |
| `bob` | `bob-password` | bob@example.com, unverified where the provider allows it |

Pocket ID only signs in with passkeys. For a one-time sign-in link:

```sh
docker compose -f dev/sso/compose.yml exec pocket-id /app/pocket-id one-time-access-token alice
```

## Adding them to Polder

In Admin → Authentication → Add provider:

| Preset | Fields | Client ID | Client secret |
| --- | --- | --- | --- |
| Keycloak | `http://localhost:8180`, realm `polder` | `polder` | `polder-keycloak-secret` |
| Authelia | `https://127.0.0.1:9091` | `polder` | `polder-authelia-secret` |
| Pocket ID | `http://localhost:1411` | `polder` | `polder-pocket-id-secret` |
| authentik | `http://localhost:9000`, slug `polder` | `polder` | `polder-authentik-secret` |

Keep the suggested button label when adding one: Polder names the provider
after it (`keycloak`, `authelia`, `pocket-id`, `authentik`), and the callback
URLs registered at the providers use those names.

## Admin consoles

| Provider | Address | Login |
| --- | --- | --- |
| Keycloak | http://localhost:8180/admin | `admin` / `admin` |
| Authelia | https://127.0.0.1:9091 | configured in `authelia/configuration.yml` |
| Pocket ID | http://localhost:1411 | `alice` is an admin; use a sign-in link |
| authentik | http://localhost:9000 | `akadmin` / `admin-password` |

## Tests

`TestLiveSingleSignOn` signs in through every running provider without a
browser: it matches existing accounts by verified email, refuses unverified
ones, creates accounts and links from the account settings.

```sh
go test -tags ssolive -run TestLiveSingleSignOn -v ./internal/app/
```

Providers that aren't running are skipped. Google, Microsoft and GitHub can't
run locally; the regular tests cover them with fake servers.

## Stop

```sh
docker compose -f dev/sso/compose.yml down      # keep the data
docker compose -f dev/sso/compose.yml down -v   # start over
```
