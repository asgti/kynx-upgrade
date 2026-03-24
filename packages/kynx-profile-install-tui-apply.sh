#!/bin/sh
set -eu

/usr/bin/kynx-profile-session-restore /

mkdir -p /etc/kynx
echo "install-tui" > /etc/kynx/profile
printf '%s\n' 'Kynx Text Install' > /etc/kynx/edition

/usr/bin/kynx-grub-visible-apply install-tui

echo "Kynx Text Install profile applied"
