#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-search-suspense.sh || true
exec /bin/bash ./apply-search-suspense.sh
