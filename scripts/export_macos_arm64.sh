#!/bin/bash
set -euo pipefail

APP_PATH="build/macOS-arm64/Electric Avenue.app"
APP_BIN="$APP_PATH/Contents/MacOS/Electric Avenue"
APP_REAL_BIN="$APP_PATH/Contents/MacOS/Electric Avenue.godot"
LAUNCHER_SRC="tools/macos_bundle_launcher.c"

godot --headless --path . --export-release "macOS" "$APP_PATH"

lipo "$APP_BIN" -extract arm64 -output "$APP_REAL_BIN"
cc -arch arm64 -mmacosx-version-min=11.0 "$LAUNCHER_SRC" -o "$APP_BIN"
codesign --force --deep --sign - "$APP_PATH"
