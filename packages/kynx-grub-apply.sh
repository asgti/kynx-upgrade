#!/bin/sh
set -eu

cat > /etc/default/grub << 'EOL'
GRUB_DISTRIBUTOR="Kynx OS"
GRUB_TIMEOUT=3
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY=true
EOL

/usr/bin/kynx-grub-write /boot "Kynx OS" /dev/vda1
echo "grub config applied"
