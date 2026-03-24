#!/bin/sh
set -eu

HOST="${1:-127.0.0.1}"
PORT="${2:-2227}"
OUT_DIR="${3:-/tmp/kynx-live-build}"

ROOTFS_STAGE="$OUT_DIR/rootfs-stage"
MEDIA_DIR="$OUT_DIR/media"

apt update
apt install -y squashfs-tools rsync openssh-client

rm -rf "$OUT_DIR"
mkdir -p "$ROOTFS_STAGE" "$MEDIA_DIR/live" "$MEDIA_DIR/boot/grub"

echo "[1/5] exporting media boot assets from running Kynx"
ssh -p "$PORT" root@"$HOST" '
  rm -rf /tmp/kynx-media-export
  mkdir -p /tmp/kynx-media-export/boot/grub
  kynx-grub-write-media /tmp/kynx-media-export/boot/grub/grub.cfg /dev/vda1
  cp -f /boot/vmlinuz-kynx /tmp/kynx-media-export/boot/vmlinuz-kynx
'

scp -P "$PORT" root@"$HOST":/tmp/kynx-media-export/boot/vmlinuz-kynx "$MEDIA_DIR/boot/vmlinuz-kynx"
scp -P "$PORT" root@"$HOST":/tmp/kynx-media-export/boot/grub/grub.cfg "$MEDIA_DIR/boot/grub/grub.cfg"

echo "[2/5] syncing running Kynx rootfs into stage"
rsync -a --numeric-ids --delete \
  -e "ssh -p $PORT" \
  --exclude='/dev/*' \
  --exclude='/proc/*' \
  --exclude='/sys/*' \
  --exclude='/run/*' \
  --exclude='/tmp/*' \
  --exclude='/mnt/*' \
  --exclude='/media/*' \
  --exclude='/root/KynxOS-LTS/*' \
  --exclude='/root/kynx-terminal*' \
  --exclude='/var/cache/apk/*' \
  --exclude='/boot/*' \
  root@"$HOST":/ "$ROOTFS_STAGE"/

mkdir -p "$ROOTFS_STAGE/boot" "$ROOTFS_STAGE/etc/kynx" "$ROOTFS_STAGE/bin"
cp -f "$MEDIA_DIR/boot/vmlinuz-kynx" "$ROOTFS_STAGE/boot/vmlinuz-kynx"

echo "[3/5] normalizing live stage"
printf '%s\n' 'live' > "$ROOTFS_STAGE/etc/kynx/profile"
printf '%s\n' 'Kynx Live' > "$ROOTFS_STAGE/etc/kynx/edition"

# احفظ inittab الأصلي حتى نكدر نرجعه لبروفايلات التثبيت
if [ -f "$ROOTFS_STAGE/etc/inittab" ]; then
  cp -f "$ROOTFS_STAGE/etc/inittab" "$ROOTFS_STAGE/etc/kynx/inittab.installed"
fi

cat > "$ROOTFS_STAGE/bin/kynx-live-login" << 'EOL'
#!/bin/sh
exec /bin/login -f kynx
EOL
chmod +x "$ROOTFS_STAGE/bin/kynx-live-login"

cat > "$ROOTFS_STAGE/bin/kynx-root-login" << 'EOL'
#!/bin/sh
exec /bin/login -f root
EOL
chmod +x "$ROOTFS_STAGE/bin/kynx-root-login"

# live الافتراضي يبقى user عادي
cat > "$ROOTFS_STAGE/etc/inittab" << 'EOL'
::sysinit:/sbin/openrc sysinit
::wait:/sbin/openrc boot
::wait:/sbin/openrc default
tty1::respawn:/sbin/getty -n -l /bin/kynx-live-login 115200 tty1 linux
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/openrc shutdown
EOL

cat > "$ROOTFS_STAGE/etc/fstab" << 'EOL'
proc      /proc  proc      defaults                   0 0
sysfs     /sys   sysfs     defaults                   0 0
devtmpfs  /dev   devtmpfs  mode=0755,nosuid           0 0
tmpfs     /run   tmpfs     mode=0755,nosuid,nodev     0 0
tmpfs     /tmp   tmpfs     mode=1777,nosuid,nodev     0 0
EOL

find "$ROOTFS_STAGE/etc/runlevels" -type l -name 'sshd' -delete 2>/dev/null || true

echo "[4/5] creating live/filesystem.squashfs"
mksquashfs "$ROOTFS_STAGE" "$MEDIA_DIR/live/filesystem.squashfs" -comp xz -b 1M -noappend

echo "[5/5] writing summary"
cat > "$OUT_DIR/README.NEXT" << EOL
Kynx live rootfs build completed.

Artifacts:
- $MEDIA_DIR/boot/vmlinuz-kynx
- $MEDIA_DIR/boot/grub/grub.cfg
- $MEDIA_DIR/live/filesystem.squashfs
EOL

echo
echo "Kynx live build prepared at: $OUT_DIR"
echo "Main artifact:"
echo "  $MEDIA_DIR/live/filesystem.squashfs"
