#!/bin/sh
set -eu

PROFILE="${1:-$(cat /etc/kynx/profile 2>/dev/null || echo live)}"
[ "$PROFILE" = "live" ] || {
  echo "not a live profile"
  exit 0
}

mkdir -p /etc/kynx

if [ ! -f /etc/kynx/inittab.installed ]; then
  cp -f /etc/inittab /etc/kynx/inittab.installed
fi

cat > /usr/bin/kynx-live-login << 'EOL'
#!/bin/sh
exec /bin/login -f kynx
EOL
chmod +x /usr/bin/kynx-live-login

cp -f /etc/kynx/inittab.installed /etc/inittab

if grep -q '^tty1::respawn:' /etc/inittab; then
  sed -i 's#^tty1::respawn:.*#tty1::respawn:/sbin/getty -n -l /usr/bin/kynx-live-login 115200 tty1 linux#' /etc/inittab
else
  printf '%s\n' 'tty1::respawn:/sbin/getty -n -l /usr/bin/kynx-live-login 115200 tty1 linux' >> /etc/inittab
fi

sed -i 's#^\(tty[2-6]::respawn:.*\)## disabled by Kynx Live lockdown: \1#' /etc/inittab || true

rc-service sshd stop 2>/dev/null || true

echo "live" > /etc/kynx/profile
touch /etc/kynx/live-lockdown-applied

echo "Kynx Live lockdown applied"
echo "- tty1 autologin => kynx"
echo "- tty2..tty6 disabled"
echo "- sshd stopped for this live session"
echo
echo "Run: init q"
