#!/bin/sh
set -eu

if command -v xmessage >/dev/null 2>&1; then
  exec xmessage -center "Kynx Graphic Install v1\nBackend is ready for probe/dry-run.\nNext step: real partition/copy/install flow."
fi

echo "Kynx Graphic Install v1"
echo "Backend is ready for probe/dry-run."
