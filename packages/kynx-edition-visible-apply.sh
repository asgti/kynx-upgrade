#!/bin/sh
set -eu

PROFILE="${1:-}"

if [ -z "$PROFILE" ]; then
  if [ -f /etc/kynx/profile ]; then
    PROFILE="$(cat /etc/kynx/profile)"
  else
    echo "usage: kynx-edition-visible-apply <live|install-gui|install-tui>"
    exit 1
  fi
fi

mkdir -p /etc/kynx /usr/share/kynx/branding /home/kynx/Desktop

case "$PROFILE" in
  live)
    EDITION_NAME="Kynx Live"
    DESKTOP_NAME="Kynx-Live.desktop"
    ;;
  install-gui)
    EDITION_NAME="Kynx Graphic Install"
    DESKTOP_NAME="Kynx-Graphic-Install.desktop"
    ;;
  install-tui)
    EDITION_NAME="Kynx Text Install"
    DESKTOP_NAME="Kynx-Text-Install.desktop"
    ;;
  *)
    echo "unknown profile: $PROFILE"
    exit 1
    ;;
esac

echo "$PROFILE" > /etc/kynx/profile
echo "$EDITION_NAME" > /etc/kynx/edition
echo "$EDITION_NAME" > /usr/share/kynx/branding/edition-name.txt

cat > /etc/issue << EOL
Welcome to Kynx OS
Edition: $EDITION_NAME
Official sites:
https://kynx.xyz
https://kynx-os.org

EOL

cat > /etc/issue.net << 'EOL'
Kynx OS
EOL

cat > /etc/motd << EOL
Kynx OS
Edition: $EDITION_NAME
Official sites:
https://kynx.xyz
https://kynx-os.org
EOL

rm -f /home/kynx/Desktop/Kynx-Current.desktop
if [ -f "/home/kynx/Desktop/$DESKTOP_NAME" ]; then
  cp -f "/home/kynx/Desktop/$DESKTOP_NAME" /home/kynx/Desktop/Kynx-Current.desktop
  chmod 755 /home/kynx/Desktop/Kynx-Current.desktop
fi

chown -R kynx:kynx /home/kynx/Desktop 2>/dev/null || true

echo "visible edition applied: $EDITION_NAME"
