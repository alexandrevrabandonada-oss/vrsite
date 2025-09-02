#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-safe-links-redirects.sh || true
exec /bin/bash ./apply-safe-links-redirects.sh
