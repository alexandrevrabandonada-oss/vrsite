#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-ui-search.sh || true
exec /bin/bash ./apply-ui-search.sh
