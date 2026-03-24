#!/bin/sh
set -eu

TARGET_ROOT="${1:-/}"

/usr/bin/kynx-profile-session-restore "$TARGET_ROOT"

mkdir -p "$TARGET_ROOT/etc/kynx"
echo "installed" > "$TARGET_ROOT/etc/kynx/profile"
printf '%s\n' 'Kynx OS' > "$TARGET_ROOT/etc/kynx/edition"

/usr/bin/kynx-grub-write "$TARGET_ROOT/boot" "Kynx OS" "/dev/vda1"

echo "Kynx installed defaults restored at: $TARGET_ROOT"
