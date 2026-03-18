#!/bin/sh
set -eu
echo "Forced post-upgrade failure for rollback test." >&2
exit 1
