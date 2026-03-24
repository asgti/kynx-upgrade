#!/bin/sh
set -eu

/usr/bin/kynx-profile-session-restore /

mkdir -p /etc/kynx
echo "install-gui" > /etc/kynx/profile
printf '%s\n' 'Kynx Graphic Install' > /etc/kynx/edition

/usr/bin/kynx-grub-visible-apply install-gui

echo "Kynx Graphic Install profile applied"
