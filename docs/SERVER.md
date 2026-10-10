# Polder server

The self-hosted Polder backend, written in Go. It provides the API, file
storage, sync, authentication, search, and the optional Flutter web app.

## Requirements

- Go 1.27+
- Flutter, for the client or web app
- Docker, for Docker and Collabora workflows

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
scripts/dev-office.sh
```

After changing the API, run `scripts/gen-client.sh` and commit the updated
OpenAPI document and generated client code. See [client/README.md](../client/README.md)
for Flutter setup and client-specific commands.
