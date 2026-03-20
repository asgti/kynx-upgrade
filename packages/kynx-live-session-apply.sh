#!/bin/sh
set -eu

mkdir -p /etc/kynx /etc/xdg/openbox /home/kynx/Desktop /usr/share/applications

echo 'live' > /etc/kynx/profile
echo 'Kynx Live' > /etc/kynx/edition

cat > /etc/xdg/openbox/autostart << 'EOL'
xsetroot -solid "#0a0f14" &
feh --bg-fill /usr/share/backgrounds/kynx/default.jpg &
tint2 &
EOL

cat > /home/kynx/Desktop/Kynx-Live.desktop << 'EOL'
[Desktop Entry]
Type=Application
Name=Kynx Live
Exec=sh -c 'rofi -show drun'
Terminal=false
Categories=System;Utility;
StartupNotify=true
EOL

chmod 755 /home/kynx/Desktop/Kynx-Live.desktop
chown -R kynx:kynx /home/kynx/Desktop 2>/dev/null || true

echo "live session applied"
