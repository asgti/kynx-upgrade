#!/bin/sh
set -eu

cat > /usr/bin/kynx-installer-gui-launcher << 'EOL'
#!/bin/sh
set -eu
if [ -x /usr/bin/kynx-installer-gui ]; then
  exec /usr/bin/kynx-installer-gui
fi
if command -v xmessage >/dev/null 2>&1; then
  exec xmessage -center "Kynx Graphic Install placeholder"
fi
exec sh -c 'echo "Kynx Graphic Install placeholder"; sleep 30'
EOL

cat > /usr/bin/kynx-installer-tui-launcher << 'EOL'
#!/bin/sh
set -eu
clear
echo "========================================"
echo "           Kynx Text Install"
echo "========================================"
echo
if [ -x /usr/bin/kynx-installer-tui ]; then
  exec /usr/bin/kynx-installer-tui
fi
echo "Placeholder: text installer not added yet."
echo
echo "Press Enter to open shell."
read dummy
exec /bin/bash
EOL

chmod +x /usr/bin/kynx-installer-gui-launcher /usr/bin/kynx-installer-tui-launcher
echo "installer placeholders applied"
