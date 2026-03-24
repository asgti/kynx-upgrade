#!/bin/sh
set -eu

OUT_FILE="${1:-/tmp/kynx-media-preview.cfg}"
ROOT_DEV="${2:-/dev/vda1}"

mkdir -p "$(dirname "$OUT_FILE")"

cat > "$OUT_FILE" << EOL
set timeout=5
set default=0

if background_image /usr/share/kynx/system/grub/kynx-wallpapers-grub.jpg; then
  true
fi

menuentry "Kynx OS - Live" {
  linux /boot/vmlinuz-kynx root=$ROOT_DEV rw rootfstype=ext4 quiet loglevel=3 vt.global_cursor_default=0 kynx.profile=live
}

menuentry "Kynx OS - Graphic Install" {
  linux /boot/vmlinuz-kynx root=$ROOT_DEV rw rootfstype=ext4 quiet loglevel=3 vt.global_cursor_default=0 kynx.profile=install-gui
}

menuentry "Kynx OS - Text Install" {
  linux /boot/vmlinuz-kynx root=$ROOT_DEV rw rootfstype=ext4 quiet loglevel=3 vt.global_cursor_default=0 kynx.profile=install-tui
}
EOL

echo "media grub menu written: $OUT_FILE"
