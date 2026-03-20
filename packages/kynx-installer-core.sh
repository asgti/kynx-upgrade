#!/bin/sh
set -eu

MODE="${1:-}"

print_disks() {
  echo "Available target disks:"
  if command -v lsblk >/dev/null 2>&1 && [ -d /sys/dev/block ]; then
    lsblk -d -o NAME,SIZE,MODEL | sed '1d' | awk '{print "/dev/"$1, $2, substr($0, index($0,$3))}'
    return 0
  fi

  awk '
    $4 ~ /^(vd|sd|hd|nvme)[a-z0-9]+$/ {
      print "/dev/" $4
    }
  ' /proc/partitions
}

check_disk() {
  DISK="${1:-}"
  [ -b "$DISK" ] || { echo "invalid disk: $DISK"; exit 1; }
}

refuse_system_disk() {
  DISK="${1:-}"
  if [ "$DISK" = "/dev/vda" ]; then
    echo "refusing to install to current system disk: $DISK"
    exit 1
  fi
}

do_dry_run() {
  DISK="${1:-}"
  check_disk "$DISK"

  echo "Kynx Installer Dry Run"
  echo "Target disk: $DISK"
  echo "Planned layout:"
  echo "  - format entire disk as ext4"
  echo "  - copy Kynx system rootfs"
  echo "  - write fstab for direct-kernel boot"
  echo "  - sync and unmount"
  echo
  echo "Installer v1 note:"
  echo "  direct-kernel rootfs install only"
  echo "  GRUB/partitioned install comes in v2"
}

do_apply() {
  DISK="${1:-}"
  check_disk "$DISK"
  refuse_system_disk "$DISK"

  TARGET_MNT="/mnt/kynx-target"

  echo "[1/6] formatting $DISK as ext4"
  if command -v wipefs >/dev/null 2>&1; then
    wipefs -a "$DISK" || true
  fi
  mkfs.ext4 -F -L KYNXROOT "$DISK"

  echo "[2/6] mounting target"
  mkdir -p "$TARGET_MNT"
  mount "$DISK" "$TARGET_MNT"

  echo "[3/6] copying root filesystem"
  rsync -aHAX --numeric-ids \
    --exclude='/proc/*' \
    --exclude='/sys/*' \
    --exclude='/dev/*' \
    --exclude='/run/*' \
    --exclude='/tmp/*' \
    --exclude='/mnt/*' \
    --exclude='/media/*' \
    --exclude='/root/KynxOS-LTS/*' \
    --exclude='/root/kynx-terminal*' \
    --exclude='/var/cache/apk/*' \
    / "$TARGET_MNT"/

  echo "[4/6] writing fstab"
  mkdir -p "$TARGET_MNT/etc"
  cat > "$TARGET_MNT/etc/fstab" << 'EOL'
/dev/vda / ext4 defaults 0 1
EOL

  echo "[5/6] syncing"
  sync

  echo "[6/6] unmounting"
  umount "$TARGET_MNT"

  echo
  echo "install completed to $DISK"
  echo "installer v1 result: direct-kernel rootfs written successfully"
}

case "$MODE" in
  probe)
    print_disks
    ;;
  dry-run)
    DISK="${2:-}"
    do_dry_run "$DISK"
    ;;
  apply)
    DISK="${2:-}"
    CONFIRM="${3:-}"
    [ "$CONFIRM" = "--yes" ] || {
      echo "usage: kynx-installer-core apply /dev/vdb --yes"
      exit 1
    }
    do_apply "$DISK"
    ;;
  *)
    echo "usage:"
    echo "  kynx-installer-core probe"
    echo "  kynx-installer-core dry-run /dev/vdX"
    echo "  kynx-installer-core apply /dev/vdX --yes"
    exit 1
    ;;
esac
