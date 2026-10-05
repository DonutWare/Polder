#!/usr/bin/env sh
# Builds the Flutter web app from client/ and copies it where `go build` embeds it
# (internal/webui/dist).
set -eu

server_dir=$(cd "$(dirname "$0")/.." && pwd)
client_dir="$server_dir/client"
dist="$server_dir/internal/webui/dist"

(
  cd "$client_dir"
  flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
)

find "$dist" -mindepth 1 ! -name .gitkeep -exec rm -rf {} +
cp -R "$client_dir/build/web/." "$dist/"
find "$dist" -name '*.symbols' -delete
echo "Web client copied to $dist; run go build to embed it."
