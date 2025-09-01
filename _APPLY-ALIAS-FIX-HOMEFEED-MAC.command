#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-alias-fix-homefeed.sh || true
exec /bin/bash ./apply-alias-fix-homefeed.sh
