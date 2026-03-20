#!/bin/sh
set -eu

if ! command -v grub-mkconfig >/dev/null 2>&1; then
  echo "grub tools are not installed"
  exit 1
fi

ASSET="/usr/share/kynx/system/grub/kynx-wallpapers-grub.jpg"

mkdir -p /etc/default /boot/grub

cat > /etc/default/grub << EOL
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Kynx"
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 vt.global_cursor_default=0"
GRUB_BACKGROUND="$ASSET"
EOL

grub-mkconfig -o /boot/grub/grub.cfg
echo "grub config generated"
