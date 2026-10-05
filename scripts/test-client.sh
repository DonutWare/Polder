#!/usr/bin/env sh
# Runs the client's integration tests (its API and sync engine) against this server.
set -eu

server_dir=$(cd "$(dirname "$0")/.." && pwd)
cd "$server_dir/client"
POLDER_SERVER_DIR="$server_dir" flutter test --tags integration "$@"
