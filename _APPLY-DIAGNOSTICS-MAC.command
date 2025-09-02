#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-diagnostics.sh || true
exec /bin/bash ./apply-diagnostics.sh
