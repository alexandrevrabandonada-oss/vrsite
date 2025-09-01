#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-search-hotfix.sh || true
exec /bin/bash ./apply-search-hotfix.sh
