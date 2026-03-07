#!/bin/sh

set -e

LOG_FILE="/var/log/kynx-kupgrade.log"
KYNX_DATA="/usr/share/kynx"
GRUB_DST="$KYNX_DATA/grub"

mkdir -p /var/log
mkdir -p "$GRUB_DST"

echo "===== Kynx post-upgrade =====" >> "$LOG_FILE"
date >> "$LOG_FILE"

if [ -f "$KYNX_DATA/system/grub/logo.png" ]; then
    cp -f "$KYNX_DATA/system/grub/logo.png" "$GRUB_DST/logo.png"
    echo "Copied: logo.png" >> "$LOG_FILE"
fi

if [ -f "$KYNX_DATA/system/grub/kynx-wallpapers-grub.jpg" ]; then
    cp -f "$KYNX_DATA/system/grub/kynx-wallpapers-grub.jpg" "$GRUB_DST/kynx-wallpapers-grub.jpg"
    echo "Copied: kynx-wallpapers-grub.jpg" >> "$LOG_FILE"
fi

echo "Post-upgrade completed successfully." >> "$LOG_FILE"
