#!/bin/sh
set -eu

mkdir -p /etc/kynx /etc/xdg/openbox /home/kynx/Desktop /usr/share/applications

echo 'install-gui' > /etc/kynx/profile
echo 'Kynx Graphic Install' > /etc/kynx/edition

cat > /etc/xdg/openbox/autostart << 'EOL'
xsetroot -solid "#0a0f14" &
feh --bg-fill /usr/share/backgrounds/kynx/default.jpg &
tint2 &
/usr/bin/kynx-installer-gui-launcher &
EOL

cat > /usr/bin/kynx-installer-gui-launcher << 'EOL'
#!/bin/sh
set -eu
if [ -x /usr/bin/kynx-installer-gui ]; then
  exec /usr/bin/kynx-installer-gui
fi
xmessage -center "Kynx Graphic Install placeholder: GUI installer not added yet."
EOL

chmod +x /usr/bin/kynx-installer-gui-launcher

cat > /home/kynx/Desktop/Kynx-Graphic-Install.desktop << 'EOL'
[Desktop Entry]
Type=Application
Name=Kynx Graphic Install
Exec=/usr/bin/kynx-installer-gui-launcher
Terminal=false
Categories=System;Utility;
StartupNotify=true
EOL

chmod 755 /home/kynx/Desktop/Kynx-Graphic-Install.desktop
chown -R kynx:kynx /home/kynx/Desktop 2>/dev/null || true

echo "install-gui profile applied"
