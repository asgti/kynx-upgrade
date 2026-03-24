#!/bin/sh
set -eu

/usr/bin/kynx-boot-profile-sync || true
/usr/bin/kynx-profile-apply || true
