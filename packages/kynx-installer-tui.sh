#!/bin/sh
set -eu

clear
echo "========================================"
echo "         Kynx Text Install"
echo "========================================"
echo

/usr/bin/kynx-installer-core probe
echo
printf 'Enter target disk (example: /dev/vda): '
read DISK
echo
/usr/bin/kynx-installer-core dry-run "$DISK"
echo
echo "This is installer backend v1 dry-run."
echo "No changes were written."
echo
echo "Press Enter to open shell."
read dummy
exec /bin/bash
