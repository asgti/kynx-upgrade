#!/bin/sh
set -eu

KYNX_ETC="/etc/kynx"

echo "=== Kynx Tools ==="

if [ -f "$KYNX_ETC/name" ]; then
    printf 'Name: '
    cat "$KYNX_ETC/name"
fi

if [ -f "$KYNX_ETC/version" ]; then
    printf 'Version: '
    cat "$KYNX_ETC/version"
fi

if [ -f "$KYNX_ETC/kernel-release" ]; then
    printf 'Kernel Release: '
    cat "$KYNX_ETC/kernel-release"
fi

if [ -f "$KYNX_ETC/channel" ]; then
    printf 'Channel: '
    cat "$KYNX_ETC/channel"
fi

if [ -f "$KYNX_ETC/home_url" ]; then
    printf 'Home: '
    cat "$KYNX_ETC/home_url"
fi

if [ -f "$KYNX_ETC/docs_url" ]; then
    printf 'Docs: '
    cat "$KYNX_ETC/docs_url"
fi

echo "=================="
