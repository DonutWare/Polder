#!/usr/bin/env sh
# Runs the server with the document editor: starts Collabora Online in Docker (unless it is already
# running) and then the server from source, configured to reach each other. Collabora keeps running
# afterwards so the next start is quick; `docker stop polder-collabora` removes it.
set -eu

server_dir=$(cd "$(dirname "$0")/.." && pwd)
container=polder-collabora
collabora_port=${COLLABORA_PORT:-9980}
listen=${POLDER_LISTEN:-:6060}
polder_port=${listen##*:}
# Collabora runs in a container, where localhost is the container itself.
wopi_url=http://host.docker.internal:$polder_port
extra_params="--o:ssl.enable=false --o:ssl.termination=false --o:admin_console.enable=false --o:welcome.enable=false --o:net.post_allow.host[0]=.+"

running_params=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$container" 2>/dev/null | sed -n 's/^extra_params=//p')
if [ "$(docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null)" != "true" ] || [ "$running_params" != "$extra_params" ]; then
  docker rm -f "$container" >/dev/null 2>&1 || true
  echo "Starting Collabora Online on port $collabora_port..."
  docker run -d --rm --name "$container" -p "127.0.0.1:$collabora_port:9980" \
    --add-host=host.docker.internal:host-gateway \
    -e "aliasgroup1=$wopi_url" \
    -e "extra_params=$extra_params" \
    collabora/code:latest >/dev/null
fi

printf "Waiting for Collabora"
until curl -sf "http://localhost:$collabora_port/hosting/discovery" >/dev/null; do
  printf "."
  sleep 2
done
echo " ready."

cd "$server_dir"
POLDER_CONFIG_DIR=${POLDER_CONFIG_DIR:-./config} \
POLDER_DATA_DIR=${POLDER_DATA_DIR:-./data} \
POLDER_LISTEN=$listen \
POLDER_COLLABORA_URL=http://localhost:$collabora_port \
POLDER_WOPI_URL=$wopi_url \
  exec go run ./cmd/polder "$@"
