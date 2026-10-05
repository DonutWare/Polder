# polder-server

The Go backend for Polder a cross-platform sync app.

The [Polder client](client/) (Flutter) lives in this repository too, so the server can embed its web build and API changes land in both in one commit.

## Run

```sh
mkdir -p config data
POLDER_UID=$(id -u) POLDER_GID=$(id -g) docker compose up -d --build
curl http://localhost:6060/healthz
```

That image includes the web app. Set `POLDER_WEB=none` for an API-only image, which skips the Flutter build.

Without Docker:

```sh
scripts/build-web.sh  
POLDER_CONFIG_DIR=./config POLDER_DATA_DIR=./data go run ./cmd/polder
```

The first login creates the admin account.

Clients receive live activity (transfers in progress, folder changes) over a WebSocket at
`/api/v1/events`. Behind a reverse proxy, let that path upgrade: in nginx, `proxy_http_version 1.1`
with `Upgrade` and `Connection` headers passed through.

## Docker image

```sh
docker build -t polder-server .                          # API only
docker build --build-arg WEB=client -t polder-server .   # with the web app from client/
```

## Development

```sh
go test ./...
golangci-lint run ./...
scripts/test-client.sh   # the client's integration tests against this server
scripts/gen-client.sh    # after changing the API: regenerate the client's API code
```

The client's API code is generated from this server's OpenAPI document. `polder openapi` prints it,
and `scripts/gen-client.sh` writes it to `client/openapi/polder.json` and regenerates
`client/lib/services/api/generated`. Commit it with the server change; CI fails while the document
there differs from the server's.

To also run the tests against MariaDB:

```sh
docker run -d --rm --name polder-test-mariadb -e MARIADB_ROOT_PASSWORD=testpass -e MARIADB_DATABASE=polder -p 33306:3306 mariadb:11
POLDER_TEST_MARIADB_DSN='root:testpass@tcp(127.0.0.1:33306)/polder' go test ./...
```
