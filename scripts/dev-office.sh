#!/usr/bin/env sh
# Runs the server with a document editor: starts Collabora Online or Euro-Office in Docker (unless it
# is already running) and then the server from source, configured to reach each other. The editor
# keeps running afterwards so the next start is quick; `docker stop polder-collabora` or
# `docker stop polder-eurooffice` removes it.
#
# Usage: scripts/dev-office.sh [collabora|eurooffice] [--editor-only | server arguments...]
#
# --editor-only starts the editor and stops there, for a server run from a debugger with
# POLDER_COLLABORA_URL=http://localhost:9980 or POLDER_EURO_OFFICE_URL=http://localhost:9981, and
# POLDER_WOPI_URL=http://host.docker.internal:6060.
set -eu

editor=collabora
case "${1:-}" in
  collabora | eurooffice)
    editor=$1
    shift
    ;;
esac
editor_only=false
if [ "${1:-}" = --editor-only ]; then
  editor_only=true
  shift
fi

server_dir=$(cd "$(dirname "$0")/.." && pwd)
container=polder-$editor
listen=${POLDER_LISTEN:-:6060}
polder_port=${listen##*:}
# The editor runs in a container, where localhost is the container itself.
wopi_url=http://host.docker.internal:$polder_port

collabora_params="--o:ssl.enable=false --o:ssl.termination=false --o:admin_console.enable=false --o:welcome.enable=false --o:net.post_allow.host[0]=.+"
# Nothing outside Euro-Office uses its JWT secret, but without one it makes up a new one on every start.
euro_office_secret=polder-development-secret-change-me

if [ "$editor" = eurooffice ]; then
  editor_port=${EURO_OFFICE_PORT:-9981}
  image=ghcr.io/euro-office/documentserver:latest
  url_variable=POLDER_EURO_OFFICE_URL
else
  editor_port=${COLLABORA_PORT:-9980}
  image=collabora/code:latest
  url_variable=POLDER_COLLABORA_URL
fi

start_collabora() {
  docker run -d --rm --name "$container" -p "127.0.0.1:$editor_port:9980" \
    --add-host=host.docker.internal:host-gateway \
    --label "polder.settings=$settings" \
    -e "aliasgroup1=$wopi_url" \
    -e "extra_params=$collabora_params" \
    "$image" >/dev/null
}

# WOPI is off by default in Euro-Office, and this server's address resolves to a private one,
# which it refuses to fetch from unless allowed.
start_eurooffice() {
  docker run -d --rm --name "$container" -p "127.0.0.1:$editor_port:80" \
    --add-host=host.docker.internal:host-gateway \
    --label "polder.settings=$settings" \
    -e WOPI_ENABLED=true \
    -e ALLOW_PRIVATE_IP_ADDRESS=true \
    -e "JWT_SECRET=$euro_office_secret" \
    "$image" >/dev/null
}

# Recreate the container when it was started with other settings.
settings="$image $wopi_url $collabora_params $euro_office_secret"
running_settings=$(docker inspect -f '{{index .Config.Labels "polder.settings"}}' "$container" 2>/dev/null || true)
if [ "$(docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null)" != "true" ] || [ "$running_settings" != "$settings" ]; then
  docker rm -f "$container" >/dev/null 2>&1 || true
  echo "Starting $editor on port $editor_port..."
  "start_$editor"
fi

printf "Waiting for %s" "$editor"
until curl -sf "http://localhost:$editor_port/hosting/discovery" >/dev/null; do
  printf "."
  sleep 2
done
echo " ready."
if [ "$editor_only" = true ]; then
  exit 0
fi

cd "$server_dir"
export "$url_variable=http://localhost:$editor_port"
POLDER_CONFIG_DIR=${POLDER_CONFIG_DIR:-./config} \
POLDER_DATA_DIR=${POLDER_DATA_DIR:-./data} \
POLDER_LISTEN=$listen \
POLDER_WOPI_URL=$wopi_url \
  exec go run ./cmd/polder "$@"
