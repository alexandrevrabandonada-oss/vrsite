#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-text-regex-flag-hotfix.sh || true
exec /bin/bash ./apply-text-regex-flag-hotfix.sh
