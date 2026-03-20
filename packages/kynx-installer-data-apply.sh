#!/bin/sh
set -eu

SRC="/usr/share/kynx/system/installer-data"
DST="/usr/share/kynx/installer-data"

mkdir -p "$DST"
cp -f "$SRC"/region_catalog.json "$DST"/region_catalog.json
cp -f "$SRC"/language_catalog.json "$DST"/language_catalog.json
cp -f "$SRC"/keyboard_catalog.json "$DST"/keyboard_catalog.json

echo "installer data applied"
