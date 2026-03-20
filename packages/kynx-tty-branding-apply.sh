#!/bin/sh
set -eu

PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
  PROFILE="$(cat /etc/kynx/profile 2>/dev/null || echo live)"
fi

case "$PROFILE" in
  live) EDITION_NAME="Kynx Live" ;;
  install-gui) EDITION_NAME="Kynx Graphic Install" ;;
  install-tui) EDITION_NAME="Kynx Text Install" ;;
  *) EDITION_NAME="Kynx OS" ;;
esac

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

mkdir -p /etc/profile.d

cat > /etc/profile.d/kynx-login-banner.sh << EOL
printf '\033c'
echo '========================================'
echo '              Kynx OS'
echo '          Edition: $EDITION_NAME'
echo '========================================'
echo
EOL

chmod +x /etc/profile.d/kynx-login-banner.sh

echo "tty branding applied: $EDITION_NAME"
