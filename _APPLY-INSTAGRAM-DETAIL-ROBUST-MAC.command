#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-instagram-detail-robust.sh || true
exec /bin/bash ./apply-instagram-detail-robust.sh
