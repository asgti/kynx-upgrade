#!/bin/sh
set -eu

PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
  PROFILE="$(cat /etc/kynx/profile 2>/dev/null || echo live)"
fi

case "$PROFILE" in
  live) LABEL="Kynx OS - Kynx Live" ;;
  install-gui) LABEL="Kynx OS - Kynx Graphic Install" ;;
  install-tui) LABEL="Kynx OS - Kynx Text Install" ;;
  *) LABEL="Kynx OS" ;;
esac

/usr/bin/kynx-grub-write /boot "$LABEL" /dev/vda1
echo "grub visible config applied: $LABEL"
