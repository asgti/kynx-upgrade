#!/bin/sh
set -eu

BOOT_DIR="${1:-/boot}"
LABEL="${2:-Kynx OS}"
ROOT_DEV="${3:-/dev/vda1}"

mkdir -p "$BOOT_DIR/grub"

cat > "$BOOT_DIR/grub/grub.cfg" << EOL
set timeout=3
set default=0

if background_image /usr/share/kynx/system/grub/kynx-wallpapers-grub.jpg; then
  true
fi

menuentry "$LABEL" {
  linux /boot/vmlinuz-kynx root=$ROOT_DEV rw rootfstype=ext4 quiet loglevel=3 vt.global_cursor_default=0
}
EOL

echo "grub config written: label=$LABEL root=$ROOT_DEV boot_dir=$BOOT_DIR"
