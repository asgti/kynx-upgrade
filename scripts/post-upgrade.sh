#!/bin/sh
set -e

LOG_FILE="/var/log/kynx-kupgrade.log"
KYNX_DATA="/usr/share/kynx"
SRC_GRUB="$KYNX_DATA/system/grub"
DST_GRUB="/boot/grub/themes/kynx"
WALLPAPER_DIR="/usr/share/backgrounds/kynx"
LOGO_DIR="/usr/share/kynx/branding"

mkdir -p /var/log
mkdir -p "$DST_GRUB"
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$LOGO_DIR"

echo "===== Kynx post-upgrade =====" >> "$LOG_FILE"
date >> "$LOG_FILE"

# GRUB files
if [ -f "$SRC_GRUB/logo.png" ]; then
    cp -f "$SRC_GRUB/logo.png" "$DST_GRUB/logo.png"
    cp -f "$SRC_GRUB/logo.png" "$LOGO_DIR/logo.png"
    echo "Copied logo.png" >> "$LOG_FILE"
fi

if [ -f "$SRC_GRUB/kynx-wallpapers-grub.jpg" ]; then
    cp -f "$SRC_GRUB/kynx-wallpapers-grub.jpg" "$DST_GRUB/kynx-wallpapers-grub.jpg"
    cp -f "$SRC_GRUB/kynx-wallpapers-grub.jpg" "$WALLPAPER_DIR/default.jpg"
    echo "Copied kynx-wallpapers-grub.jpg" >> "$LOG_FILE"
fi

# System identity
cat > /etc/issue << 'EOF'
Kynx OS Beta 1.0
Kernel: \r
Host: \n
Console: \l

Official sites:
- https://kynx.xyz
- https://kynx-os.org
EOF

cat > /etc/motd << 'EOF'
Welcome to Kynx OS Beta 1.0

Official sites:
https://kynx.xyz
https://kynx-os.org
EOF

cat > /etc/os-release << 'EOF'
NAME="Kynx OS"
PRETTY_NAME="Kynx OS Beta 1.0"
ID=kynx
VERSION="Beta 1.0"
VERSION_ID="1.0"
HOME_URL="https://kynx.xyz"
DOCUMENTATION_URL="https://kynx-os.org"
SUPPORT_URL="https://kynx-os.org"
BUG_REPORT_URL="https://kynx-os.org"
ANSI_COLOR="1;36"
EOF

echo "Updated /etc/issue" >> "$LOG_FILE"
echo "Updated /etc/motd" >> "$LOG_FILE"
echo "Updated /etc/os-release" >> "$LOG_FILE"

echo "Post-upgrade completed successfully." >> "$LOG_FILE"
