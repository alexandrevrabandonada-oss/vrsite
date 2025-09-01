#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-search-pack.sh || true
exec /bin/bash ./apply-search-pack.sh
