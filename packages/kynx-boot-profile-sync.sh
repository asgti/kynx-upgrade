#!/bin/sh
set -eu

CMDLINE="$(cat /proc/cmdline 2>/dev/null || true)"
PROFILE=""

for token in $CMDLINE; do
  case "$token" in
    kynx.profile=*)
      PROFILE="${token#kynx.profile=}"
      ;;
  esac
done

[ -n "$PROFILE" ] || exit 0

mkdir -p /etc/kynx

case "$PROFILE" in
  live|install-gui|install-tui|installed|os)
    echo "$PROFILE" > /etc/kynx/profile
    ;;
  *)
    echo "unknown boot profile from cmdline: $PROFILE"
    exit 1
    ;;
esac

case "$PROFILE" in
  live)
    printf '%s\n' 'Kynx Live' > /etc/kynx/edition
    ;;
  install-gui)
    printf '%s\n' 'Kynx Graphic Install' > /etc/kynx/edition
    ;;
  install-tui)
    printf '%s\n' 'Kynx Text Install' > /etc/kynx/edition
    ;;
  installed|os)
    printf '%s\n' 'Kynx OS' > /etc/kynx/edition
    ;;
esac

echo "boot profile synced from cmdline: $PROFILE"
