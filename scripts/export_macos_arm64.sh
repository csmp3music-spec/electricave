#!/bin/bash
set -euo pipefail

APP_PATH="build/macOS-arm64/Electric Avenue.app"
APP_BIN="$APP_PATH/Contents/MacOS/Electric Avenue"
APP_REAL_BIN="$APP_PATH/Contents/MacOS/Electric Avenue.godot"
APP_PLIST="$APP_PATH/Contents/Info.plist"
LAUNCHER_SRC="tools/macos_bundle_launcher.c"
SPARKLE_FRAMEWORK_SRC="${GODOT_SPARKLE_FRAMEWORK:-/Applications/Summer.app/Contents/Frameworks/Sparkle.framework}"

mkdir -p "$(dirname "$APP_PATH")"
rm -rf "$APP_PATH"

godot --headless --path . --export-release "macOS" "$APP_PATH"

# Some locally bundled Godot templates link Sparkle but omit the framework and
# app metadata from exported bundles. Complete those pieces before signing.
if otool -L "$APP_BIN" | grep -q '@rpath/Sparkle.framework'; then
  if [ ! -d "$SPARKLE_FRAMEWORK_SRC" ]; then
    echo "Sparkle.framework is required by the macOS export template but was not found at: $SPARKLE_FRAMEWORK_SRC" >&2
    echo "Set GODOT_SPARKLE_FRAMEWORK to the framework's full path and rebuild." >&2
    exit 1
  fi
  mkdir -p "$APP_PATH/Contents/Frameworks"
  cp -R "$SPARKLE_FRAMEWORK_SRC" "$APP_PATH/Contents/Frameworks/"
fi

if [ ! -f "$APP_PLIST" ]; then
  plutil -create xml1 "$APP_PLIST"
  plutil -insert CFBundleDevelopmentRegion -string en "$APP_PLIST"
  plutil -insert CFBundleDisplayName -string "Electric Avenue" "$APP_PLIST"
  plutil -insert CFBundleExecutable -string "Electric Avenue" "$APP_PLIST"
  plutil -insert CFBundleIdentifier -string com.electricave.electricavenue "$APP_PLIST"
  plutil -insert CFBundleInfoDictionaryVersion -string 6.0 "$APP_PLIST"
  plutil -insert CFBundleName -string "Electric Avenue" "$APP_PLIST"
  plutil -insert CFBundlePackageType -string APPL "$APP_PLIST"
  plutil -insert CFBundleShortVersionString -string 1.0 "$APP_PLIST"
  plutil -insert CFBundleVersion -string 1.0 "$APP_PLIST"
  plutil -insert LSMinimumSystemVersion -string 11.0 "$APP_PLIST"
  plutil -insert NSHighResolutionCapable -bool true "$APP_PLIST"
fi

# On critically full developer volumes, the exported app plus import cache can
# leave too little space for lipo's temporary output. Keep the cache during
# normal builds so launching the source project after export does not produce
# missing-import errors.
available_kb="$(df -Pk . | awk 'NR == 2 { print $4 }')"
if [ "${available_kb:-0}" -lt 1048576 ]; then
  echo "Less than 1 GiB free; clearing the generated Godot import cache."
  rm -rf .godot/imported
fi

if lipo -info "$APP_BIN" 2>&1 | grep -q "Architectures in the fat file"; then
  lipo "$APP_BIN" -extract arm64 -output "$APP_REAL_BIN"
else
  mv "$APP_BIN" "$APP_REAL_BIN"
fi
cc -arch arm64 -mmacosx-version-min=11.0 "$LAUNCHER_SRC" -o "$APP_BIN"
codesign --force --deep --sign - "$APP_PATH"
