#!/bin/sh
set -eu

mkdir -p /etc/local.d /var/lib/kynx

cat > /etc/local.d/kynx-firstboot.start << 'EOL'
#!/bin/sh
STAMP="/var/lib/kynx/base-tools.installed"
[ -f "$STAMP" ] && exit 0
/usr/bin/kynx-base-tools || exit 0
exit 0
EOL

chmod +x /etc/local.d/kynx-firstboot.start
rc-update add local default 2>/dev/null || true

echo "firstboot base-tools hook enabled"
