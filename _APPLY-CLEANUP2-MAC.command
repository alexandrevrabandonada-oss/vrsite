#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-cleanup2.sh || true
exec /bin/bash ./apply-cleanup2.sh
