# Polder and Nextcloud

A local setup for testing federation (Open Cloud Mesh) between Polder and
Nextcloud. Caddy serves both over https with its own certificate authority,
which both servers trust. Nextcloud and Caddy run in Docker; Polder runs from
this checkout, in the VS Code debugger or in a container.

| Server | Address | Login |
| --- | --- | --- |
| Polder | https://polder.test | create the first account on first visit |
| Nextcloud | https://nextcloud.test | `admin` / `admin` |

## Once

Add the names to `/etc/hosts`:

```sh
echo "127.0.0.1 polder.test nextcloud.test" | sudo tee -a /etc/hosts
```

Run `sh dev/nextcloud/start.sh` from the repository root. It starts Caddy and
Nextcloud and exports Caddy's certificate authority to
`dev/nextcloud/caddy-root.crt`. The first time it stops and prints the command
that trusts that certificate on the Mac; Polder needs it to reach Nextcloud,
and the browser shows no warnings with it. Run the command, then start again.

Caddy needs port 443 on localhost, and Nextcloud takes a few minutes to
install itself on the first start.

## Start

In VS Code, run **Server (Nextcloud)**, or **Server (Nextcloud) + Client** for
the app as well. It starts the containers first and serves the web client
built into the server, with your usual development data in `config` and
`data`.

To run Polder in a container instead, from this directory:

```sh
POLDER_UPSTREAM=polder:6060 docker compose --profile container up -d
docker compose logs -f polder
```

## Connect them

1. In Polder, open the admin settings, turn on federation and trust
   `nextcloud.test` with **Allow private network** on. Both names point at
   local addresses.
2. Nextcloud needs no setup: it shares with any server once it allows local
   servers, which the install hook turns on. Share with `<user>@polder.test`
   from Nextcloud and with `admin@nextcloud.test` from Polder. Leave
   Nextcloud's **Trusted servers** setting alone; it only accepts other
   Nextcloud servers and answers "No Nextcloud server" for Polder.
3. In Nextcloud's share box, type `jop@polder.test` and pick
   **jop (polder.test)**. The install hook turns off sharing by email, which
   would otherwise offer the same address as an email share.

Nextcloud sends OCM shares without the certificates imported with `occ`, so
the container also adds Caddy's certificate authority to its system store.

Every request between the servers passes through Caddy. In a container,
Polder sees unsigned requests come from Caddy's address rather than the
sender's; if it rejects an unsigned request from Nextcloud, trust it with the
address check off.

## After changing Polder

Restart the launch configuration, or `docker compose restart polder` for the
container. The web client is the one in `internal/webui/dist`; run
`scripts/build-web.sh` from the repository root to rebuild it.

## Reset

```sh
docker compose --profile container down -v
```
