#!/bin/sh
set -eu

PROFILE="${1:-$(cat /etc/kynx/profile 2>/dev/null || echo installed)}"

case "$PROFILE" in
  live)
    exec /usr/bin/kynx-profile-live-apply live
    ;;
  install-gui)
    exec /usr/bin/kynx-profile-install-gui-apply
    ;;
  install-tui)
    exec /usr/bin/kynx-profile-install-tui-apply
    ;;
  installed|os)
    exec /usr/bin/kynx-profile-installed-apply /
    ;;
  *)
    echo "unknown Kynx profile: $PROFILE"
    exit 1
    ;;
esac
