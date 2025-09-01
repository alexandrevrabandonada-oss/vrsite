#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-text-lib-replace.sh || true
exec /bin/bash ./apply-text-lib-replace.sh
