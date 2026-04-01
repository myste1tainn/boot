#!/bin/bash

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <DMG_URL>"
  exit 1
fi

DMG_URL="$1"
TMP_DIR=$(mktemp -d)
MOUNT_POINT="/Volumes/InstallTemp"
DEST_DIR="$HOME/Applications"

mkdir -p "$DEST_DIR"

echo "➡️  Resolving download URL..."
# Try to get filename from headers
FILENAME=$(curl -sIL "$DMG_URL" | grep -i 'Content-Disposition:' | sed -E 's/.*filename="?([^"]+)"?/\1/' | tail -n1)

if [[ -z "$FILENAME" ]]; then
  FILENAME="downloaded.dmg"
fi

DMG_PATH="$TMP_DIR/$FILENAME"

echo "➡️  Downloading to $DMG_PATH..."
curl -L "$DMG_URL" -o "$DMG_PATH"

echo "➡️  Mounting the DMG..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT" -nobrowse -quiet

APP_PATH=$(find "$MOUNT_POINT" -maxdepth 1 -name "*.app" -print -quit)
if [ -z "$APP_PATH" ]; then
  echo "❌ No .app found in the DMG."
  hdiutil detach "$MOUNT_POINT" -quiet
  rm -rf "$TMP_DIR"
  exit 1
fi

APP_NAME=$(basename "$APP_PATH")
DEST="$DEST_DIR/$APP_NAME"

echo "➡️  Installing $APP_NAME to $DEST_DIR..."
cp -R "$APP_PATH" "$DEST"

echo "➡️  Unmounting..."
hdiutil detach "$MOUNT_POINT" -quiet

echo "➡️  Cleaning up..."
rm -rf "$TMP_DIR"

echo "✅ Installed $APP_NAME to $DEST_DIR"

