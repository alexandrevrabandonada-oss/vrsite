#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-instagram-debug.sh || true
exec /bin/bash ./apply-instagram-debug.sh
