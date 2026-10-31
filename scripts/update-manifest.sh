#!/usr/bin/env bash
set -euo pipefail

channel=${1:?channel}
version=${2:?version}
build=${3:?build number}
tag=${4:?release tag}
macos=${5:?macOS zip}
windows=${6:?Windows setup}
linux=${7:?Linux AppImage}

if [ -z "${UPDATE_SIGNING_KEY:-}" ]; then
  echo "UPDATE_SIGNING_KEY is not set; desktop clients can't verify an unsigned update manifest" >&2
  exit 1
fi

asset() {
  jq -n \
    --arg name "$(basename "$1")" \
    --arg sha256 "$(openssl dgst -sha256 -r "$1" | cut -d ' ' -f1)" \
    --argjson size "$(wc -c < "$1" | tr -d ' ')" \
    '{name: $name, sha256: $sha256, size: $size}'
}

jq -n \
  --arg channel "$channel" \
  --arg version "$version" \
  --argjson build "$build" \
  --arg tag "$tag" \
  --arg commit "${GITHUB_SHA:-}" \
  --arg notesUrl "https://github.com/DonutWare/Polder/releases/tag/$tag" \
  --argjson macos "$(asset "$macos")" \
  --argjson windows "$(asset "$windows")" \
  --argjson linux "$(asset "$linux")" \
  '{channel: $channel, version: $version, build: $build, tag: $tag, commit: $commit, notesUrl: $notesUrl,
    assets: {macos: $macos, windows: $windows, linux: $linux}}' > update.json

key=$(mktemp)
trap 'rm -f "$key"' EXIT
printf '%s\n' "$UPDATE_SIGNING_KEY" > "$key"
openssl pkeyutl -sign -inkey "$key" -rawin -in update.json | openssl base64 -A > update.json.sig
