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

partition_path() {
  DISK="${1:-}"
  case "$DISK" in
    *nvme*|*mmcblk*) echo "${DISK}p1" ;;
    *) echo "${DISK}1" ;;
  esac
}

ensure_tools() {
  for c in sfdisk wipefs mkfs.ext4 rsync grub-install; do
    command -v "$c" >/dev/null 2>&1 || {
      echo "missing tool: $c"
      echo "install with: apk add --no-cache util-linux e2fsprogs rsync grub grub-bios"
      exit 1
    }
  done

  [ -f /usr/share/kynx/system/boot/vmlinuz-kynx ] || {
    echo "missing kernel asset: /usr/share/kynx/system/boot/vmlinuz-kynx"
    exit 1
  }
}

do_dry_run() {
  DISK="${1:-}"
  PART="$(partition_path "$DISK")"
  check_disk "$DISK"

  echo "Kynx Installer Dry Run"
  echo "Target disk: $DISK"
  echo "Target root partition: $PART"
  echo "Planned layout:"
  echo "  - wipe disk"
  echo "  - create msdos partition table"
  echo "  - create ext4 root partition"
  echo "  - copy Kynx system rootfs"
  echo "  - copy kernel to /boot/vmlinuz-kynx"
  echo "  - write fstab"
  echo "  - write grub.cfg"
  echo "  - install BIOS GRUB"
}

do_apply_v2() {
  DISK="${1:-}"
  PART="$(partition_path "$DISK")"
  TARGET_MNT="/mnt/kynx-target"

  check_disk "$DISK"
  refuse_system_disk "$DISK"
  ensure_tools

  echo "[1/8] wiping disk signatures"
  umount "$PART" 2>/dev/null || true
  wipefs -a "$DISK" || true

  echo "[2/8] partitioning disk"
  printf 'label: dos\n, ,L,*\n' | sfdisk "$DISK"
  sync
  sleep 2

  [ -b "$PART" ] || {
    echo "partition not found after partitioning: $PART"
    exit 1
  }

  echo "[3/8] formatting $PART as ext4"
  mkfs.ext4 -F -L KYNXROOT "$PART"

  echo "[4/8] mounting target"
  mkdir -p "$TARGET_MNT"
  mount "$PART" "$TARGET_MNT"
  mkdir -p "$TARGET_MNT/boot" "$TARGET_MNT/etc"

  echo "[5/8] copying root filesystem"
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

  echo "[6/8] installing boot files"
  cp -f /usr/share/kynx/system/boot/vmlinuz-kynx "$TARGET_MNT/boot/vmlinuz-kynx"

  cat > "$TARGET_MNT/etc/fstab" << 'EOL'
/dev/vda1 / ext4 defaults 0 1
EOL

  mkdir -p "$TARGET_MNT/boot/grub"
  cat > "$TARGET_MNT/boot/grub/grub.cfg" << 'EOL'
set timeout=3
set default=0

if background_image /usr/share/kynx/system/grub/kynx-wallpapers-grub.jpg; then
  true
fi

menuentry "Kynx OS" {
  linux /boot/vmlinuz-kynx root=/dev/vda1 rw rootfstype=ext4 quiet loglevel=3 vt.global_cursor_default=0
}
EOL

  echo "[7/8] installing grub"
  grub-install \
    --target=i386-pc \
    --boot-directory="$TARGET_MNT/boot" \
    --modules="part_msdos ext2 biosdisk" \
    "$DISK"

  echo "[8/8] syncing and unmounting"
  sync
  umount "$TARGET_MNT"

  echo
  echo "install completed to $DISK"
  echo "installer v2 result: partitioned disk + grub installed successfully"
}

case "$MODE" in
  probe)
    print_disks
    ;;
  dry-run)
    DISK="${2:-}"
    do_dry_run "$DISK"
    ;;
  apply-v2)
    DISK="${2:-}"
    CONFIRM="${3:-}"
    [ "$CONFIRM" = "--yes" ] || {
      echo "usage: kynx-installer-core apply-v2 /dev/vdb --yes"
      exit 1
    }
    do_apply_v2 "$DISK"
    ;;
  *)
    echo "usage:"
    echo "  kynx-installer-core probe"
    echo "  kynx-installer-core dry-run /dev/vdX"
    echo "  kynx-installer-core apply-v2 /dev/vdX --yes"
    exit 1
    ;;
esac
