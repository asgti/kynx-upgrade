#!/bin/sh
set -eu

mkdir -p /etc/kynx /usr/bin

echo 'install-tui' > /etc/kynx/profile
echo 'Kynx Text Install' > /etc/kynx/edition

cat > /usr/bin/kynx-installer-tui-launcher << 'EOL'
#!/bin/sh
set -eu
if [ -x /usr/bin/kynx-installer-tui ]; then
  exec /usr/bin/kynx-installer-tui
fi
echo "Kynx Text Install placeholder: TUI installer not added yet."
EOL

chmod +x /usr/bin/kynx-installer-tui-launcher

echo "install-tui profile applied"
