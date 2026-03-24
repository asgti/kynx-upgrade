#!/bin/sh
set -eu

TARGET_ROOT="${1:-/}"

mkdir -p "$TARGET_ROOT/etc/kynx"

if [ -f "$TARGET_ROOT/etc/kynx/inittab.installed" ]; then
  cp -f "$TARGET_ROOT/etc/kynx/inittab.installed" "$TARGET_ROOT/etc/inittab"
fi

rm -f "$TARGET_ROOT/usr/bin/kynx-live-login"

echo "standard session defaults restored at: $TARGET_ROOT"
