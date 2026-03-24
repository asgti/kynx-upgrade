#!/bin/sh
set -eu

/usr/bin/kynx-profile-session-restore /

mkdir -p /etc/kynx
echo "install-tui" > /etc/kynx/profile
printf '%s\n' 'Kynx Text Install' > /etc/kynx/edition

cat > /etc/inittab << 'EOL'
::sysinit:/sbin/openrc sysinit
::wait:/sbin/openrc boot
::wait:/sbin/openrc default
tty1::respawn:/sbin/getty -n -l /bin/kynx-root-login 115200 tty1 linux
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/openrc shutdown
EOL

/usr/bin/kynx-grub-visible-apply install-tui

echo "Kynx Text Install profile applied"
