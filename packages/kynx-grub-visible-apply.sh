#!/bin/sh
set -eu

PROFILE="${1:-$(cat /etc/kynx/profile 2>/dev/null || echo live)}"

case "$PROFILE" in
  live) LABEL="Kynx OS - Live" ;;
  install-gui) LABEL="Kynx OS - Graphic Install" ;;
  install-tui) LABEL="Kynx OS - Text Install" ;;
  *) LABEL="Kynx OS" ;;
esac

/usr/bin/kynx-grub-write /boot "$LABEL" /dev/vda1
echo "grub visible config applied: $LABEL"
