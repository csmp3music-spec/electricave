#!/bin/bash
set -euo pipefail

APP_PATH="build/macOS-arm64/Electric Avenue.app"
APP_BIN="$APP_PATH/Contents/MacOS/Electric Avenue"
APP_REAL_BIN="$APP_PATH/Contents/MacOS/Electric Avenue.godot"
LAUNCHER_SRC="tools/macos_bundle_launcher.c"

mkdir -p "$(dirname "$APP_PATH")"
rm -rf "$APP_PATH"

godot --headless --path . --export-release "macOS" "$APP_PATH"

# On very full developer volumes, the exported app plus import cache can leave
# too little space for lipo's temporary output. The cache is generated.
rm -rf .godot/imported

if lipo -info "$APP_BIN" 2>&1 | grep -q "Architectures in the fat file"; then
  lipo "$APP_BIN" -extract arm64 -output "$APP_REAL_BIN"
else
  mv "$APP_BIN" "$APP_REAL_BIN"
fi
cc -arch arm64 -mmacosx-version-min=11.0 "$LAUNCHER_SRC" -o "$APP_BIN"
codesign --force --deep --sign - "$APP_PATH"
