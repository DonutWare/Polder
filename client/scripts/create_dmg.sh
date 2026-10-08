#!/bin/bash
set -e

APP_NAME="Polder"
APP_PATH="build/macos/Build/Products/Release/Polder.app"
DMG_PATH="build/macos/Build/Products/Release/macOS.dmg"
TEMP_DMG_DIR="dmg_temp"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH, build it first with: flutter build macos"
    exit 1
fi

rm -rf "$TEMP_DMG_DIR"
rm -f "$DMG_PATH"
mkdir -p "$TEMP_DMG_DIR"
cp -R "$APP_PATH" "$TEMP_DMG_DIR/"

create-dmg \
    --volname "$APP_NAME" \
    --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
    --window-pos 200 120 \
    --window-size 800 500 \
    --icon-size 80 \
    --icon "$APP_NAME.app" 210 250 \
    --hide-extension "$APP_NAME.app" \
    --app-drop-link 603 250 \
    --format UDZO \
    --hdiutil-quiet \
    "$DMG_PATH" \
    "$TEMP_DMG_DIR"

rm -rf "$TEMP_DMG_DIR"
echo "DMG created at $DMG_PATH ($(du -h "$DMG_PATH" | cut -f1))"
