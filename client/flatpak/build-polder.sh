#!/bin/sh
set -eu

APP_ID=org.knaapen.polder
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
cd apps/polder
flutter build linux --release \
  --build-number="$BUILD_NUMBER" \
  --dart-define=POLDER_CHANNEL="$POLDER_CHANNEL" \
  --dart-define=POLDER_UPDATE_PUBLIC_KEY="$POLDER_UPDATE_PUBLIC_KEY"

mkdir -p /app/polder /app/bin
cp -r build/linux/x64/prod/release/bundle/. /app/polder/
ln -sf /app/polder/polder /app/bin/polder

install -Dm644 web/icons/Icon-512.png "/app/share/icons/hicolor/512x512/apps/$APP_ID.png"
install -d /app/share/applications
sed -e "s/^Icon=.*/Icon=$APP_ID/" -e "/^\[Desktop Entry\]/a StartupWMClass=$APP_ID" \
  "linux/$APP_ID.desktop" > "/app/share/applications/$APP_ID.desktop"
install -Dm644 "flatpak/$APP_ID.metainfo.xml" "/app/share/metainfo/$APP_ID.metainfo.xml"
