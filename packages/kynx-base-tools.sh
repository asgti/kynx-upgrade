#!/bin/sh
set -eu

STAMP="/var/lib/kynx/base-tools.installed"
mkdir -p /var/lib/kynx

if [ "${1:-}" != "--force" ] && [ -f "$STAMP" ]; then
  echo "base tools already installed"
  exit 0
fi

apk update
apk add --no-cache \
  bash curl wget ca-certificates \
  nano git jq file rsync \
  unzip zip xz htop \
  openssh e2fsprogs dosfstools \
  pciutils usbutils

rc-update add sshd default 2>/dev/null || true

date > "$STAMP"
echo "base tools installed"
