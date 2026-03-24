#!/bin/sh
set -eu

mkdir -p /etc/init.d

cat > /etc/init.d/kynx-boot-profile << 'EOL'
#!/sbin/openrc-run
name="kynx-boot-profile"
description="Apply Kynx profile from kernel command line"

depend() {
  need localmount
  before display-manager
  before sshd
}

start() {
  ebegin "Applying Kynx boot profile"
  /usr/bin/kynx-boot-apply-profile
  eend $?
}
EOL

chmod +x /etc/init.d/kynx-boot-profile

rc-update add kynx-boot-profile default

echo "kynx-boot-profile OpenRC service installed"
