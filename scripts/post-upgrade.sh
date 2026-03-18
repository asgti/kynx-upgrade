#!/bin/sh
set -eu

LOG_FILE="/var/log/kynx-kupgrade.log"
KYNX_SHARE="/usr/share/kynx"
KYNX_ETC="/etc/kynx"
KYNX_APPS="/opt/kynx/apps"
KYNX_STATE="/var/lib/kynx"
KYNX_BRANDING="/usr/share/kynx/branding"
KYNX_WALLPAPERS="/usr/share/backgrounds/kynx"
SRC_SYSTEM_GRUB="$KYNX_SHARE/system/grub"
OS_RELEASE_FILE="/usr/lib/os-release"

KYNX_VER="$(cat "$KYNX_SHARE/version.txt" 2>/dev/null || echo "unknown")"

mkdir -p /var/log
mkdir -p "$KYNX_ETC"
mkdir -p "$KYNX_APPS"
mkdir -p "$KYNX_STATE"
mkdir -p "$KYNX_BRANDING"
mkdir -p "$KYNX_WALLPAPERS"

log() {
    printf '%s\n' "$1" >> "$LOG_FILE"
}

log "===== Kynx post-upgrade ====="
date >> "$LOG_FILE"
log "Version: $KYNX_VER"

if [ -f "$KYNX_SHARE/version.txt" ]; then
    cp -f "$KYNX_SHARE/version.txt" "$KYNX_ETC/repo-version"
    log "Updated /etc/kynx/repo-version"
fi

if [ -f "$KYNX_SHARE/manifest.json" ]; then
    cp -f "$KYNX_SHARE/manifest.json" "$KYNX_ETC/manifest.json"
    log "Updated /etc/kynx/manifest.json"
fi

if [ -f "$SRC_SYSTEM_GRUB/logo.png" ]; then
    cp -f "$SRC_SYSTEM_GRUB/logo.png" "$KYNX_BRANDING/logo.png"
    log "Copied branding logo"
fi

if [ -f "$SRC_SYSTEM_GRUB/kynx-wallpapers-grub.jpg" ]; then
    cp -f "$SRC_SYSTEM_GRUB/kynx-wallpapers-grub.jpg" "$KYNX_WALLPAPERS/default.jpg"
    log "Copied default wallpaper"
fi

cat > /etc/issue << EOF_ISSUE
Kynx OS Beta $KYNX_VER
Kernel: \r
Host: \n
Console: \l

Official sites:
- https://kynx.xyz
- https://kynx-os.org
EOF_ISSUE

cat > /etc/motd << EOF_MOTD
Welcome to Kynx OS Beta $KYNX_VER

Official sites:
https://kynx.xyz
https://kynx-os.org
EOF_MOTD

cat > "$OS_RELEASE_FILE" << EOF_OS
NAME="Kynx OS"
PRETTY_NAME="Kynx OS Beta $KYNX_VER"
ID=kynx
VERSION="Beta $KYNX_VER"
VERSION_ID="$KYNX_VER"
HOME_URL="https://kynx.xyz"
DOCUMENTATION_URL="https://kynx-os.org"
SUPPORT_URL="https://kynx-os.org"
BUG_REPORT_URL="https://kynx-os.org"
ANSI_COLOR="1;36"
EOF_OS

log "Updated /etc/issue"
log "Updated /etc/motd"
log "Updated $OS_RELEASE_FILE"
log "Post-upgrade completed successfully."

echo "Kynx post-upgrade completed."
