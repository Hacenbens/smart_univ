#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Release build script — SmartCampus
#
# Produces an obfuscated APK (sideload) and AAB (Play Store) with a matching
# symbol map written to build/debug-info/.
#
# ⚠  SECURITY: build/debug-info/ is excluded from git (.gitignore: /build/).
#    Back it up to a secure location (e.g. encrypted cloud storage) after
#    every release — it is the only way to de-symbolicate crash reports.
#
# Usage:
#   bash scripts/build_release.sh          # APK + AAB
#   bash scripts/build_release.sh apk      # APK only
#   bash scripts/build_release.sh aab      # AAB only
# ---------------------------------------------------------------------------
set -euo pipefail

TARGET="${1:-both}"
DEBUG_INFO_DIR="build/debug-info"

mkdir -p "$DEBUG_INFO_DIR"

COMMON_FLAGS=(
  --release
  --obfuscate
  --split-debug-info="$DEBUG_INFO_DIR"
)

build_apk() {
  echo "▶  Building obfuscated APK…"
  flutter build apk "${COMMON_FLAGS[@]}"
  echo "✔  APK → build/app/outputs/flutter-apk/app-release.apk"
}

build_aab() {
  echo "▶  Building obfuscated AAB (Play Store)…"
  flutter build appbundle "${COMMON_FLAGS[@]}"
  echo "✔  AAB → build/app/outputs/bundle/release/app-release.aab"
}

case "$TARGET" in
  apk)  build_apk ;;
  aab)  build_aab ;;
  both) build_apk; build_aab ;;
  *)
    echo "Unknown target: $TARGET  (valid: apk | aab | both)"
    exit 1
    ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Debug symbols written to: $DEBUG_INFO_DIR/"
echo "  ⚠  Store securely — required for crash de-symbolication."
echo "  ⚠  Never commit this directory to version control."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
