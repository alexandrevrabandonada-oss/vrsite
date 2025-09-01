#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-fix-app-files.sh || true
exec /bin/bash ./apply-fix-app-files.sh
