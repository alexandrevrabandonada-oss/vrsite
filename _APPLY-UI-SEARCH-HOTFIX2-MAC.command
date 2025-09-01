#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-ui-search-hotfix2.sh || true
exec /bin/bash ./apply-ui-search-hotfix2.sh
