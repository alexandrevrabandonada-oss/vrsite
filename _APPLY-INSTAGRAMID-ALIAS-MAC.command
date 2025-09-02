#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-instagramid-alias.sh || true
exec /bin/bash ./apply-instagramid-alias.sh
