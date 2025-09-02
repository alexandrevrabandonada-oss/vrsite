#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-ig-unified-data.sh || true
exec /bin/bash ./apply-ig-unified-data.sh
