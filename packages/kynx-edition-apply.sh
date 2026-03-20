#!/bin/sh
set -eu

EDITION="${1:-}"

if [ -z "$EDITION" ]; then
  echo "usage: kynx-edition-apply <live|install-gui|install-tui>"
  exit 1
fi

mkdir -p /etc/kynx /etc/xdg/openbox /home/kynx /etc/profile.d

case "$EDITION" in
  live)
    echo 'live' > /etc/kynx/profile
    echo 'Kynx Live' > /etc/kynx/edition

    cat > /home/kynx/.profile << 'EOL'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
EOL

    cat > /etc/xdg/openbox/autostart << 'EOL'
xsetroot -solid "#0a0f14" &
feh --bg-fill /usr/share/backgrounds/kynx/default.jpg &
tint2 &
EOL

    rm -f /etc/profile.d/kynx-install-tui.sh
    ;;

  install-gui)
    echo 'install-gui' > /etc/kynx/profile
    echo 'Kynx Graphic Install' > /etc/kynx/edition

    cat > /home/kynx/.profile << 'EOL'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
EOL

    cat > /etc/xdg/openbox/autostart << 'EOL'
xsetroot -solid "#0a0f14" &
feh --bg-fill /usr/share/backgrounds/kynx/default.jpg &
tint2 &
/usr/bin/kynx-installer-gui-launcher &
EOL

    rm -f /etc/profile.d/kynx-install-tui.sh
    ;;

  install-tui)
    echo 'install-tui' > /etc/kynx/profile
    echo 'Kynx Text Install' > /etc/kynx/edition

    cat > /home/kynx/.profile << 'EOL'
# no graphical auto-start in text install mode
EOL

    cat > /etc/profile.d/kynx-install-tui.sh << 'EOL'
if [ "$(tty)" = "/dev/tty1" ] && [ -x /usr/bin/kynx-installer-tui-launcher ]; then
  /usr/bin/kynx-installer-tui-launcher
fi
EOL
    chmod +x /etc/profile.d/kynx-install-tui.sh
    ;;

  *)
    echo "unknown edition: $EDITION"
    exit 1
    ;;
esac

chown kynx:kynx /home/kynx/.profile 2>/dev/null || true
chmod 644 /home/kynx/.profile

echo "edition applied: $EDITION"
