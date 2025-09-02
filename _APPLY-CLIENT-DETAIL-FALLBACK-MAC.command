#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-client-detail-fallback.sh || true
exec /bin/bash ./apply-client-detail-fallback.sh
