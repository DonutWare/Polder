#!/bin/sh
set -eu

APP=${1:?app directory under apps/}
BINARY=${2:?binary name}
ICON=${3:?icon path inside the app directory}
APP_ID=${FLATPAK_ID:?run through flatpak-builder}
BUILD_NUMBER=1
POLDER_CHANNEL=dev
POLDER_UPDATE_PUBLIC_KEY=
[ -f flatpak/build.env ] && . flatpak/build.env

export TAR_OPTIONS=--no-same-owner
export FLUTTER_ROOT="$PWD/.flutter-sdk"
export PUB_CACHE="$PWD/.pub-cache"
export PATH="$FLUTTER_ROOT/bin:$PATH"

FLUTTER_VERSION=$(sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' .fvmrc)
git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_ROOT"

flutter config --no-analytics --no-cli-animations
flutter pub get
cd "apps/$APP"
flutter build linux --release \
  --build-number="$BUILD_NUMBER" \
  --dart-define=POLDER_CHANNEL="$POLDER_CHANNEL" \
  --dart-define=POLDER_UPDATE_PUBLIC_KEY="$POLDER_UPDATE_PUBLIC_KEY"

mkdir -p "/app/$BINARY" /app/bin
cp -r build/linux/x64/prod/release/bundle/. "/app/$BINARY/"
ln -sf "/app/$BINARY/$BINARY" "/app/bin/$BINARY"

case "$ICON" in
  *.svg) install -Dm644 "$ICON" "/app/share/icons/hicolor/scalable/apps/$APP_ID.svg" ;;
  *) install -Dm644 "$ICON" "/app/share/icons/hicolor/512x512/apps/$APP_ID.png" ;;
esac
install -d /app/share/applications
sed -e "s/^Icon=.*/Icon=$APP_ID/" -e "/^\[Desktop Entry\]/a StartupWMClass=$APP_ID" \
  "linux/$APP_ID.desktop" > "/app/share/applications/$APP_ID.desktop"
install -Dm644 "../../flatpak/$APP_ID.metainfo.xml" "/app/share/metainfo/$APP_ID.metainfo.xml"
