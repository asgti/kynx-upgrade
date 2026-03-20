#!/bin/sh
set -eu

mkdir -p \
  /etc \
  /usr/lib \
  /usr/share/kynx/branding \
  /usr/share/icons/hicolor/256x256/apps \
  /usr/share/pixmaps \
  /usr/share/applications

cat > /etc/os-release << 'EOL'
NAME="Kynx OS"
ID=kynx
PRETTY_NAME="Kynx OS"
HOME_URL="https://kynx.xyz"
DOCUMENTATION_URL="https://kynx-os.org"
EOL

cat > /usr/lib/os-release << 'EOL'
NAME="Kynx OS"
ID=kynx
PRETTY_NAME="Kynx OS"
HOME_URL="https://kynx.xyz"
DOCUMENTATION_URL="https://kynx-os.org"
EOL

cat > /etc/issue << 'EOL'
Welcome to Kynx OS
Official sites:
https://kynx.xyz
https://kynx-os.org

EOL

cat > /etc/issue.net << 'EOL'
Kynx OS
EOL

cat > /etc/motd << 'EOL'
Kynx OS
Official sites:
https://kynx.xyz
https://kynx-os.org
EOL

echo 'kynx' > /etc/hostname
echo 'Kynx OS' > /usr/share/kynx/branding/system-name.txt

LOGO_SRC=""
for p in \
  /usr/share/kynx/branding/logo.png \
  /usr/share/kynx/system/grub/logo.png
do
  if [ -f "$p" ]; then
    LOGO_SRC="$p"
    break
  fi
done

if [ -n "$LOGO_SRC" ]; then
  cp -f "$LOGO_SRC" /usr/share/icons/hicolor/256x256/apps/kynx.png
  cp -f "$LOGO_SRC" /usr/share/pixmaps/kynx.png
fi

for f in \
  /usr/share/applications/kynx-live.desktop \
  /usr/share/applications/kynx-graphic-install.desktop \
  /usr/share/applications/kynx-text-install.desktop
do
  [ -f "$f" ] || continue
  grep -q '^Icon=' "$f" && sed -i 's/^Icon=.*/Icon=kynx/' "$f" || echo 'Icon=kynx' >> "$f"
done

for f in /home/kynx/Desktop/*.desktop; do
  [ -f "$f" ] || continue
  grep -q '^Icon=' "$f" && sed -i 's/^Icon=.*/Icon=kynx/' "$f" || echo 'Icon=kynx' >> "$f"
done

chown -R kynx:kynx /home/kynx/Desktop 2>/dev/null || true

echo "visible branding applied"
