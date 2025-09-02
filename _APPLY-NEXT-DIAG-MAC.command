#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-next-diag.sh || true
exec /bin/bash ./apply-next-diag.sh
