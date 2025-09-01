#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-cleanup.sh || true
exec /bin/bash ./apply-cleanup.sh
