#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-fix-imports.sh || true
exec /bin/bash ./apply-fix-imports.sh
