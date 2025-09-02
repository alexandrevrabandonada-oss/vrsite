#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-instagram-safe.sh || true
exec /bin/bash ./apply-instagram-safe.sh
