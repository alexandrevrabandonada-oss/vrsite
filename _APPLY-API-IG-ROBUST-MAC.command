#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-api-ig-robust.sh || true
exec /bin/bash ./apply-api-ig-robust.sh
