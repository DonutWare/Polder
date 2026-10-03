#!/usr/bin/env sh
# Regenerates the client's API code from this server's OpenAPI document.
set -eu

server_dir=$(cd "$(dirname "$0")/.." && pwd)
client_dir="$server_dir/client"

spec=$(mktemp)
trap 'rm -f "$spec"' EXIT
(cd "$server_dir" && go run ./cmd/nomad openapi) > "$spec"
cat "$spec" > "$client_dir/openapi/nomad.json"
(
  cd "$client_dir"
  rm -rf lib/services/api/generated
  dart run build_runner build
  dart format lib/services/api/generated
)
